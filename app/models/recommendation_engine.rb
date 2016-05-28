require 'matrix'
class RecommendationEngine
  DEFAULT_MIN_RAM = 1
  DEFAULT_DEPENDENCY_WEIGHT = 100
  def compute_recommendation(ingredient)
    # TODO: 1) Generate or refresh or use cached provider data 2) Generate ingredient data 3) Execute MiniZinc
    ActiveRecord::Base.transaction do
    end
  end

  # TODO(Joel): Ensure that the order of ingredients is deterministic (order by id?)
  def generate_minizinc_ingredients(ingredient)
    all_leafs = ingredient.all_leafs
    num_ingredients = all_leafs.count
    # TODO: Determine semantics of dependency constraint (e.g., unidirectional or bidirectional network traffic?)
    dependencies = Hash.new
    all_leafs.each do |i|
      i.dependency_constraints.each do |dc|
        source_index = all_leafs.index(dc.source)
        target_index = all_leafs.index(dc.target)
        # TODO: Determine semantics of dependency constraint (e.g., unidirectional or bidirectional network traffic?)
        dependencies[[source_index,target_index]] = DEFAULT_DEPENDENCY_WEIGHT
        # dependencies[[target_index,source_index]] = DEFAULT_DEPENDENCY_WEIGHT
      end
    end
    inter_ingredient_traffic = Matrix.build(num_ingredients, num_ingredients) do |row, col|
      if dependencies[[row,col]]
        dependencies[[row,col]]
      else
        0
      end
    end.to_a.flatten
    min_ram = ingredient.all_leafs.collect do |i|
      i.ram_constraints.first.min_ram rescue DEFAULT_MIN_RAM
    end

    # TODO(Joel): Save to tmp subdirectory (consider rails envs; e.g., test vs development)
    minizinc_ingredients = File.join(Rails.root, 'lib', 'ingredients.dzn')
    File.open(minizinc_ingredients, 'w') do |file|
        file.write("num_ingredients = #{num_ingredients};")
        file.write "\n"
        file.write("inter_ingredient_traffic = array2d(Ingredients, Ingredients, #{inter_ingredient_traffic.to_json});")
        file.write "\n"
        file.write("min_ram = #{min_ram.to_json};")
        file.write "\n"
    end
  end
end
