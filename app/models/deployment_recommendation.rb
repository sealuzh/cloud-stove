require 'matrix'
require 'tempfile'

class DeploymentRecommendation < Base
  DEFAULT_MIN_RAM = 1
  DEFAULT_MIN_CPUS = 1
  DEFAULT_DEPENDENCY_WEIGHT = 100

  belongs_to :ingredient

  def self.construct(ingredient)
    ingredient.deployment_recommendation.destroy if ingredient.deployment_recommendation
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
    output = `mzn-g12fd #{Rails.root}/lib/stove.mzn #{resources.path} #{ingredients.path}`
    if $?.success?
      output.gsub!(', ]', ']')
      results = output.split(soln_sep)
      last_result = results[results.size - 2] # last entry contains the search complete msg
      self.more_attributes = last_result
      self.save! # serializes `more_attributes` into a hash
      ingredient_ids = self.ingredient.all_leafs.sort_by(&:id).map(&:id)
      resource_ids = lookup_resource_ids(self.more_attributes['ingredients'])
      ingredients_hash = Hash[ingredient_ids.zip(resource_ids)]
      self.more_attributes['ingredients'] = ingredients_hash
      self.save!
    else
      fail "Error executing MiniZinc:\n#{output}"
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
    resources_data = ''
    resources_data << "num_resources = #{Resource.count};"

    resources = Resource.all
    resources_data << "resource_ids = #{resources.map(&:name).to_json};"

    prices = resources.map { |r| (r.price_per_month * 1000).to_i }
    resources_data << "costs = #{prices.to_json};"

    ram_mb = resources.map { |r| (BigDecimal.new(r.ma['mem_gb']) * 1024).to_i rescue 0 }
    resources_data << "ram = #{ram_mb.to_json};"

    cores = resources.map { |r| r.ma['cores'].to_i rescue 0 }
    resources_data << "cpu = #{cores};"

    transfer_costs = Matrix.build(resources.count, resources.count) do |row, col|
      # FIXME: use actual transfer costs!
      (resources[row].provider_id - resources[col].provider_id).abs * 100
    end
    resources_data << "transfer_costs = array2d(Resources, Resources, #{transfer_costs.to_a.flatten.to_json});"
    self.resources_data = resources_data
  end

  def generate_ingredients_data
    ingredients_data = ''

    all_leafs = ingredient.all_leafs.sort_by &:id
    num_ingredients = all_leafs.count
    ingredients_data << "num_ingredients = #{num_ingredients};"
    ingredients_data << "\n"

    ingredients_data << "inter_ingredient_traffic = array2d(Ingredients, Ingredients,
                          #{inter_ingredient_traffic(all_leafs).to_a.flatten.to_json});"
    ingredients_data << "\n"

    min_ram = ingredient.all_leafs.collect do |i|
      i.ram_constraints.first.min_ram rescue DEFAULT_MIN_RAM
    end
    ingredients_data << "min_ram = #{min_ram.to_json};"
    ingredients_data << "\n"

    min_cpus = ingredient.all_leafs.collect do |i|
      i.cpu_constraints.first.min_cpus rescue DEFAULT_MIN_CPUS
    end
    ingredients_data << "min_cpus = #{min_cpus.to_json};"
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


  def as_json(options={})
    hash = extract_params(self)

    ingredients = []
    hash[:recommendation].each do |ingredient_id, resource_id|
      entry = {}
      entry[:ingredient] = Ingredient.find(ingredient_id.to_i).as_json
      entry[:resource] = Resource.find(resource_id).as_json
      ingredients << entry
    end

    hash[:recommendation] = ingredients
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
      hash
    end
end
