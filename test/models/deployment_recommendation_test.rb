require 'test_helper'

# NOTICE: Workloads are not considered here unless
# `@rails_app.update_constraints` is called explicitly
class DeploymentRecommendationTest < ActiveSupport::TestCase
  SEEDS_ROOT = Rails.root + 'db/seeds/'
  def load_seed(name)
    load ("#{SEEDS_ROOT}#{name}.rb")
  end

  setup do
    load_seed 'admin_user'
    load_seed 'ingredient_instance_rails_app_test'
    @rails_app = Ingredient.where(name: 'Rails Application with PostgreSQL Backend', is_template: false).first
  end

  test 'generate deployment recommendation' do
    create(:amazon_provider)
    create(:google_provider)

    recommendation = DeploymentRecommendation.construct(@rails_app)

    expected_resources = %w(g1-small g1-small g1-small).collect { |n|  Resource.find_by_name(n) }
    ingredient_ids = @rails_app.children.sort_by(&:id).map(&:id)
    resource_codes = expected_resources.collect(&:resource_code)
    ingredients_hash = Hash[ingredient_ids.zip(resource_codes)]
    region_codes = expected_resources.collect(&:region_code)
    expected_recommendation =  {
      'ingredients' => ingredients_hash,
      'regions' => region_codes,
      'num_resources' => [ '2', '3', '2' ],
      'vm_cost' => '109.37',
      'total_cost' => 109375
    }
    # Example JSON:
    # {"ingredients"=>{3=>1207022094, 4=>1207022094, 5=>3159946989},
    #  "regions"=>[3005993341, 3005993341, 3005993341],
    #  "vm_cost"=>"634.63",
    #  "total_cost"=>634632}
    assert_equal expected_recommendation, recommendation.more_attributes
  end

  test 'region constraint on root ingredient' do
    @rails_app.preferred_region_area_constraint = PreferredRegionAreaConstraint.create(preferred_region_area: 'US')
    create(:amazon_provider)
    create(:google_provider)
    create(:azure_provider)

    recommendation = DeploymentRecommendation.construct(@rails_app)

    expected_resources = %w(A0 A0 A0).collect { |n|  Resource.find_by_name(n) }
    ingredient_ids = @rails_app.children.sort_by(&:id).map(&:id)
    resource_codes = expected_resources.collect(&:resource_code)
    ingredients_hash = Hash[ingredient_ids.zip(resource_codes)]
    region_codes = expected_resources.collect(&:region_code)
    assert_equal region_codes, recommendation.more_attributes['regions']
  end

  test 'hierarchical region constraint' do
    @rails_app.preferred_region_area_constraint = PreferredRegionAreaConstraint.create(preferred_region_area: 'US')
    lb = Ingredient.find_by_name('NGINX')
    lb.preferred_region_area_constraint = PreferredRegionAreaConstraint.create(preferred_region_area: 'EU')
    create(:amazon_provider)
    create(:google_provider)
    create(:azure_provider)

    recommendation = DeploymentRecommendation.construct(@rails_app)

    expected_resources = %w(A2 A3 g1-small).collect { |n|  Resource.find_by_name(n) }
    ingredient_ids = @rails_app.children.sort_by(&:id).map(&:id)
    resource_codes = expected_resources.collect(&:resource_code)
    ingredients_hash = Hash[ingredient_ids.zip(resource_codes)]
    region_codes = expected_resources.collect(&:region_code)
    assert_equal region_codes, recommendation.more_attributes['regions']
  end

  # Tests for vertically scaled apps

  test '[vertical scaling] unsatisfiable constraint' do
    create(:amazon_provider)
    rc = @rails_app.children.first.ram_constraint
    rc.min_ram = 16_000_000
    rc.save!
    sc = @rails_app.children.first.scaling_constraint
    sc.max_num_instances = 1
    sc.save!

    recommendation = DeploymentRecommendation.construct(@rails_app)
    # No instance available with more than 15GB RAM
    assert_equal DeploymentRecommendation::UNSATISFIABLE, recommendation.status
    # assert_equal 'constraint forall(i in Ingredients)(ram[assignments[i]] >= min_ram[i]);', recommendation.more_attributes['unsatisfiable_message']
  end
  
  test '[vertical scaling] generate deployment recommendation' do
    create(:amazon_provider)
    create(:google_provider)
    @rails_app.children.each do |c|
      sc = c.scaling_constraint
      sc.max_num_instances = 1
      sc.save!
      cc = c.cpu_constraint
      cc.min_cpus = 0.01
      cc.save!
    end

    recommendation = DeploymentRecommendation.construct(@rails_app)

    expected_resources = %w(c3.2xlarge c3.2xlarge t2.micro).collect { |n|  Resource.find_by_name(n) }
    ingredient_ids = @rails_app.children.sort_by(&:id).map(&:id)
    resource_codes = expected_resources.collect(&:resource_code)
    ingredients_hash = Hash[ingredient_ids.zip(resource_codes)]
    region_codes = expected_resources.collect(&:region_code)
    expected_recommendation =  {
      'ingredients' => ingredients_hash,
      'num_resources' => ['1'] * ingredient_ids.count,
      'regions' => region_codes,
      'vm_cost' => '634.63',
      'total_cost' => 634635
    }
    # Example JSON:
    # {"ingredients"=>{3=>123, 4=>123, 5=>122, 6=>123},
    #  "regions"=>[3005993341, 3005993341, 3005993341, 3005993341],
    #  "vm_cost"=>"947.11",
    #  "total_cost"=>947112}
    assert_equal expected_recommendation, recommendation.more_attributes
  end

  test '[vertical scaling] region constraint on root ingredient' do
    @rails_app.preferred_region_area_constraint = PreferredRegionAreaConstraint.create(preferred_region_area: 'US')
    create(:amazon_provider)
    create(:google_provider)
    create(:azure_provider)
    @rails_app.children.each do |c|
      sc = c.scaling_constraint
      sc.max_num_instances = 1
      sc.save!
    end

    recommendation = DeploymentRecommendation.construct(@rails_app)

    expected_resources = %w(A2 A3 A1).collect { |n|  Resource.find_by_name(n) }
    ingredient_ids = @rails_app.children.sort_by(&:id).map(&:id)
    resource_codes = expected_resources.collect(&:resource_code)
    ingredients_hash = Hash[ingredient_ids.zip(resource_codes)]
    region_codes = expected_resources.collect(&:region_code)
    expected_recommendation = {
      'ingredients' => ingredients_hash,
      'num_resources' => ['1'] * ingredient_ids.count,
      'regions' => region_codes,
      'vm_cost' => '475.42',
      'total_cost' => 475419
    }
    assert_equal expected_recommendation, recommendation.more_attributes
  end

  test '[vertical scaling] hierarchical region constraint' do
    @rails_app.preferred_region_area_constraint = PreferredRegionAreaConstraint.create(preferred_region_area: 'US')
    lb = Ingredient.find_by_name('NGINX')
    lb.preferred_region_area_constraint = PreferredRegionAreaConstraint.create(preferred_region_area: 'EU')
    create(:amazon_provider)
    create(:google_provider)
    create(:azure_provider)
    @rails_app.children.each do |c|
      sc = c.scaling_constraint
      sc.max_num_instances = 1
      sc.save!
      cc = c.cpu_constraint
      cc.min_cpus = 0.01
      cc.save!
    end

    recommendation = DeploymentRecommendation.construct(@rails_app)

    expected_resources = %w(A2 A3 t2.micro).collect { |n|  Resource.find_by_name(n) }
    ingredient_ids = @rails_app.children.sort_by(&:id).map(&:id)
    resource_codes = expected_resources.collect(&:resource_code)
    ingredients_hash = Hash[ingredient_ids.zip(resource_codes)]
    region_codes = expected_resources.collect(&:region_code)
    expected_recommendation = {
        'ingredients' => ingredients_hash,
        'num_resources' => ['1'] * ingredient_ids.count,
        'regions' => region_codes,
        'vm_cost' => '414.41',
        'total_cost' => 434411
    }
    assert_equal expected_recommendation, recommendation.more_attributes
  end
end
