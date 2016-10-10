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

  # MiniZinc
  SOLN_SEP = '----------' # '--soln-sep'
  SEARCH_COMPLETE_MSG = '==========' # '--search-complete-msg'
  UNSATISFIABLE_MSG = '=====UNSATISFIABLE====='

  # Status
  UNSATISFIABLE = 'unsatisfiable'
  SATISFIABLE = 'satisfiable'

  belongs_to :ingredient
  belongs_to :user

  scope :satisfiable, -> { where("deployment_recommendations.status != ? or deployment_recommendations.status IS NULL", UNSATISFIABLE) }
  scope :unsatisfiable, -> { where(status: UNSATISFIABLE) }

  def self.construct(ingredient, provider_id = nil)
    recommendation = DeploymentRecommendation.create(ingredient: ingredient, num_simultaneous_users: ingredient.num_simultaneous_users)
    recommendation.generate_resources_data(provider_id)
    recommendation.generate_ingredients_data(provider_id)
    recommendation.generate
    recommendation.user = recommendation.ingredient.user
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

    command = "minizinc -G or-tools -f fzn-or-tools #{minizinc_model} #{resources.path} #{ingredients.path}"
    stdout, stderr, status = Open3.capture3(command)
    if status.success?
      parse_result(stdout, stderr)
    else
      fail [ 'Error executing MiniZinc!',
             '----------stdout----------',
             stdout,
             '----------stderr----------',
             stderr,
             '--------------------------' ].join("\n")
    end

    ensure
    resources.unlink
    ingredients.unlink
  end

  def minizinc_model
    "#{Rails.root}/lib/stove.mzn"
  end

  def parse_result(stdout, stderr)
    result = extract_result(stdout)
    if satisfiable?(result)
      self.status = SATISFIABLE
      self.more_attributes = result
      unless self.save # serializes `more_attributes` result string into a hash
        err_msg = self.errors.full_messages
        self.destroy!
        fail [ 'Error parsing MiniZinc output!',
               '----------result----------',
               result,
               '----------error----------',
               err_msg,
               '--------------------------' ].join("\n")
      end

      mapping = ingredient_resource_mapping(self.more_attributes['ingredients'])
      self.more_attributes['ingredients'] = mapping
      self.save!
    else
      self.status = UNSATISFIABLE
      self.more_attributes = unsatisfiable_msg(stderr)
      self.save!
    end
  end

  def unsatisfiable_msg(stderr)
      line = line_with_error(stderr)
    { unsatisfiable_message: line_from_minizinc_model(line) }
  rescue NoMethodError
    { unsatisfiable_message: 'Could not localize MiniZinc error!' }
  end

  def line_from_minizinc_model(line)
    File.readlines(minizinc_model)[line - 1].strip
  end

  MINIZINC_ERROR_REGEX = /lib\/stove\.mzn:(\d+):/
  def line_with_error(stderr)
    MINIZINC_ERROR_REGEX.match(stderr)[1].to_i
  end

  def extract_result(output)
    output.gsub!(', ]', ']')
    results = output.split(SOLN_SEP)
    results[results.size - 2] # last entry contains the search complete msg
  end

  def satisfiable?(result)
    !result.include?(UNSATISFIABLE_MSG)
  end

  def ingredient_resource_mapping(ingredient_resources)
    ingredient_ids = self.ingredient.all_leafs.sort_by(&:id).map(&:id)
    resource_codes = ingredient_resources.map(&:to_i)
    Hash[ingredient_ids.zip(resource_codes)]
  end

  def generate_resources_data(provider_id)
    resources = filtered_resources(provider_id)

    resources_data = ''
    resources_data << "num_resources = #{resources.count};"
    resources_data << "\n"

    resources_data << "resources = #{resources.map(&:resource_code).to_json};"
    resources_data << "\n"

    resources_data << "regions = #{resources.map(&:region_code).to_json};"
    resources_data << "\n"

    prices = resources.map { |r| (r.price_per_month.to_f * 1000).to_i }
    resources_data << "costs = #{prices.to_json};"
    resources_data << "\n"

    ram_mb = resources.map { |r| ((r.ma['mem_gb'].to_f) * 1024).to_i }
    resources_data << "ram = #{ram_mb.to_json};"
    resources_data << "\n"

    cores = resources.map { |r| r.ma['cores'].to_i rescue 0 }
    resources_data << "cpu = #{cores};"
    resources_data << "\n"

    resources_data << "transfer_costs = array2d(Resources, Resources, #{transfer_costs(resources).to_a.flatten.to_json});"
    self.resources_data = resources_data
  end

  def filtered_resources(provider_id)
    if provider_id
      Resource.where(provider_id: provider_id).region_area(self.ingredient.preferred_region_areas).compute.sort_by(&:id)
    else
      Resource.region_area(self.ingredient.preferred_region_areas).compute.sort_by(&:id)
    end
  end

  def transfer_costs(resources)
    Matrix.build(resources.count, resources.count) do |row, col|
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
  end

  def generate_ingredients_data(provider_id)
    ingredients_data = ''

    all_leafs = self.ingredient.all_leafs
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
                          #{preferred_regions(self.ingredient, provider_id).to_json});"
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

  # Returns a flattened Ingredients to Resources mapping array
  def preferred_regions(ingredient, provider_id)
    resource_region_codes = filtered_resources(provider_id).map(&:region_code)
    region_areas = ingredient.region_constraints
    regions = Array.new
    region_areas.each do |region_area|
      preferred_region_codes = Set.new(Resource.region_codes(region_area))
      regions.push(resource_region_codes.map { |rrc| preferred_region_codes.member?(rrc) })
    end
    regions.flatten
  end

  def as_json(options={})
    hash = extract_params(self)

    ingredients = []
    hash[:recommendation].each do |ingredient_id, resource_code|
      entry = {}
      entry[:ingredient] = Ingredient.find(ingredient_id.to_i).as_json({:children => false, :constraints => false})
      entry[:resource] = Resource.find_by_resource_code(resource_code).as_json({:children => false, :constraints => false})
      ingredients << entry
    end

    hash[:recommendation] = ingredients
    hash[:num_simultaneous_users] = self.num_simultaneous_users
    hash[:application] = self.ingredient.as_json({:children => false, :constraints => false})
    hash[:status] = self.status
    hash[:unsatisfiable_message] = self.more_attributes['unsatisfiable_message'] if self.status == UNSATISFIABLE
    hash
  end

  def embed_ingredients
    hash = extract_params(self)

    ingredients = []
    hash[:recommendation].each do |ingredient_id, resource_code|
      entry = {}
      entry[:ingredient] = Ingredient.find(ingredient_id.to_i)
      entry[:resource] = Resource.find_by_resource_code(resource_code)
      ingredients << entry
    end

    hash[:recommendation] = ingredients
    hash[:num_simultaneous_users] = self.num_simultaneous_users
    hash[:status] = self.status
    hash[:unsatisfiable_message] = self.more_attributes['unsatisfiable_message'] if self.status == UNSATISFIABLE
    hash
  end

  private

    def extract_params(recommendation)
      hash = {}
      hash[:id] = self.id
      hash[:vm_cost] = recommendation.more_attributes['vm_cost']
      hash[:total_cost] = recommendation.more_attributes['total_cost']
      hash[:recommendation] = (recommendation.more_attributes['ingredients']) ? recommendation.more_attributes['ingredients'] : []
      hash[:created_at] = recommendation.created_at
      hash[:updated_at] = recommendation.updated_at
      hash
    end
end
