require 'matrix'
require 'set'
require 'tempfile'
require 'open3'

class DeploymentRecommendation < Base
  # Constraint defaults
  DEFAULT_MIN_RAM = 1
  DEFAULT_MIN_CPUS = 1
  DEFAULT_DEPENDENCY_WEIGHT = 100
  DEFAULT_REGION_AREAS = %w(EU)

  # Transfer costs
  INTRA_REGION_TRANSFER = 0
  INTER_REGION_SAME_PROVIDER_TRANSFER = 10
  INTER_REGION_DIFFERENT_PROVIDER_TRANSFER = 30
  INTER_REGION_AREA_TRANSFER = 100

  belongs_to :ingredient

  def self.construct(ingredient)
    recommendation = DeploymentRecommendation.create(ingredient: ingredient)
    recommendation.generate_resources_data
    recommendation.generate_ingredients_data
    recommendation.generate
    recommendation.save!
    recommendation
  end

  # @pre providers and resources must already exist
  def generate
    resources = Tempfile.new(%w(resources .dzn))
    resources.write self.resources_data
    resources.close
    ingredients = Tempfile.new(%w(ingredients .dzn))
    ingredients.write self.ingredients_data
    ingredients.close

    soln_sep = "----------" # '--soln-sep'
    search_complete_msg = "==========" # '--search-complete-msg'
    command = "minizinc -G or-tools -f fzn-or-tools #{Rails.root}/lib/stove.mzn #{resources.path} #{ingredients.path}"
    stdout, stderr, status = Open3.capture3(command)
    if status.success?
      stdout.gsub!(', ]', ']')
      results = stdout.split(soln_sep)
      last_result = results[results.size - 2] # last entry contains the search complete msg
      self.more_attributes = last_result
      self.save! # serializes `more_attributes` into a hash
      ingredient_ids = self.ingredient.all_leafs.sort_by(&:id).map(&:id)
      resource_ids = lookup_resource_ids(self.more_attributes['ingredients'])
      ingredients_hash = Hash[ingredient_ids.zip(resource_ids)]
      self.more_attributes['ingredients'] = ingredients_hash
      self.save!
    else
      fail "Error executing MiniZinc!\n
            ----------stdout----------\n
            #{stdout}\n
            ----------stderr----------\n
            #{stderr}
            --------------------------"
    end

    ensure
    resources.unlink
    ingredients.unlink
  end

  # Maps an array resource strings into an array of resource ids
  # Example: ["c3.2xlarge", "c3.2xlarge", "t2.micro", "c3.2xlarge"] => [120, 120, 119, 120]
  def lookup_resource_ids(resource_strings)
    resource_strings.map { |s| Resource.find_by_name(s).id }
  end

  def generate_resources_data
    resources = filtered_resources

    resources_data = ''
    resources_data << "num_resources = #{resources.count};"
    resources_data << "\n"

    resources_data << "resource_ids = #{resources.map(&:name).to_json};"
    resources_data << "\n"

    resources_data << "regions = #{resources.map(&:region_code).to_json};"
    resources_data << "\n"

    prices = resources.map { |r| (r.price_per_month * 1000).to_i }
    resources_data << "costs = #{prices.to_json};"
    resources_data << "\n"

    ram_mb = resources.map { |r| (BigDecimal.new(r.ma['mem_gb']) * 1024).to_i rescue 0 }
    resources_data << "ram = #{ram_mb.to_json};"
    resources_data << "\n"

    cores = resources.map { |r| r.ma['cores'].to_i rescue 0 }
    resources_data << "cpu = #{cores};"
    resources_data << "\n"

    transfer_costs = Matrix.build(resources.count, resources.count) do |row, col|
      # FIXME: use actual transfer costs!
      if resources[row].region_code == resources[col].region_code
        INTRA_REGION_TRANSFER
      elsif resources[row].region_area == resources[col].region_area
        if resources[row].provider_id == resources[col].provider_id
          INTER_REGION_SAME_PROVIDER_TRANSFER
        else
          INTER_REGION_DIFFERENT_PROVIDER_TRANSFER
        end
      else
        INTER_REGION_AREA_TRANSFER
      end
    end
    resources_data << "transfer_costs = array2d(Resources, Resources, #{transfer_costs.to_a.flatten.to_json});"
    self.resources_data = resources_data
  end

  def filtered_resources
    Resource.region_area(preferred_region_areas).compute.sort_by(&:id)
  end

  def preferred_region_areas
    all_leafs = ingredient.all_leafs.sort_by(&:id)
    areas = Set.new
    all_leafs.each do |leaf|
      if leaf.preferred_region_area_constraint.present?
        areas.add(leaf.preferred_region_area_constraint.preferred_region_area)
      end
    end
    areas.empty? ? DEFAULT_REGION_AREAS : areas.to_a
  end

  def generate_ingredients_data
    ingredients_data = ''

    all_leafs = ingredient.all_leafs.sort_by(&:id)
    num_ingredients = all_leafs.count
    ingredients_data << "num_ingredients = #{num_ingredients};"
    ingredients_data << "\n"

    ingredients_data << "inter_ingredient_traffic = array2d(Ingredients, Ingredients,
                          #{inter_ingredient_traffic(all_leafs).to_a.flatten.to_json});"
    ingredients_data << "\n"

    min_ram = all_leafs.collect do |i|
      i.ram_constraint.min_ram rescue DEFAULT_MIN_RAM
    end
    ingredients_data << "min_ram = #{min_ram.to_json};"
    ingredients_data << "\n"

    min_cpus = all_leafs.collect do |i|
      i.cpu_constraint.min_cpus rescue DEFAULT_MIN_CPUS
    end
    ingredients_data << "min_cpus = #{min_cpus.to_json};"
    ingredients_data << "\n"

    ingredients_data << "preferred_regions = array2d(Ingredients, Resources,
                          #{preferred_regions(all_leafs).to_a.flatten.to_json});"
    ingredients_data << "\n"

    self.ingredients_data = ingredients_data
  end

  def inter_ingredient_traffic(all_leafs)
    dependencies = Hash.new
    all_leafs.each do |i|
      i.dependency_constraints.each do |dc|
        source_index = all_leafs.index(dc.source)
        target_index = all_leafs.index(dc.target)
        # Use bi-directional dependency
        dependencies[[source_index,target_index]] = DEFAULT_DEPENDENCY_WEIGHT
        dependencies[[target_index,source_index]] = DEFAULT_DEPENDENCY_WEIGHT
      end
    end
    Matrix.build(all_leafs.count, all_leafs.count) do |row, col|
      if dependencies[[row,col]]
        dependencies[[row,col]]
      else
        0
      end
    end
  end

  def preferred_regions(all_leafs)
    resource_region_codes = filtered_resources.map(&:region_code)
    regions = Array.new
    all_leafs.each do |ingredient|
      if ingredient.preferred_region_area_constraint.present?
        preferred_region_codes = Set.new(ingredient.preferred_region_area_constraint.region_codes)
        regions.push(resource_region_codes.map { |rrc| preferred_region_codes.member?(rrc) })
      else
        regions.push(Array.new(resource_region_codes.count, true))
      end
    end
    regions.flatten
  end

  def as_json(options={})
    hash = extract_params(self)

    ingredients = []
    hash[:recommendation].each do |ingredient_id, resource_id|
      entry = {}
      entry[:ingredient] = Ingredient.find(ingredient_id.to_i).as_json({:children => false, :constraints => false})
      entry[:resource] = Resource.find(resource_id).as_json({:children => false, :constraints => false})
      ingredients << entry
    end

    hash[:recommendation] = ingredients
    hash[:application] = self.ingredient.as_json({:children => false, :constraints => false})
    hash
  end

  def embed_ingredients
    hash = extract_params(self)

    ingredients = []
    hash[:recommendation].each do |ingredient_id, resource_id|
      entry = {}
      entry[:ingredient] = Ingredient.find(ingredient_id.to_i)
      entry[:resource] = Resource.find(resource_id)
      ingredients << entry
    end

    hash[:recommendation] = ingredients
    hash
  end

  private

    def extract_params(recommendation)
      hash = {}
      hash[:vm_cost] = recommendation.more_attributes['vm_cost']
      hash[:total_cost] = recommendation.more_attributes['total_cost']
      hash[:recommendation] = (recommendation.more_attributes['ingredients']) ? recommendation.more_attributes['ingredients'] : []
      hash[:created_at] = recommendation.created_at
      hash[:updated_at] = recommendation.updated_at
      hash
    end
end
