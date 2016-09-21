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

    expected_resources = %w(c3.2xlarge c3.2xlarge t2.micro).collect { |n|  Resource.find_by_name(n) }
    ingredient_ids = @rails_app.children.sort_by(&:id).map(&:id)
    resource_ids = expected_resources.collect(&:id)
    ingredients_hash = Hash[ingredient_ids.zip(resource_ids)]
    region_codes = expected_resources.collect(&:region_code)
    expected_recommendation =  {
      'ingredients' => ingredients_hash,
      'regions' => region_codes,
      'vm_cost' => '634.63',
      'total_cost' => 634632
    }
    # Example JSON:
    # {"ingredients"=>{3=>123, 4=>123, 5=>122, 6=>123},
    #  "regions"=>[3005993341, 3005993341, 3005993341, 3005993341],
    #  "vm_cost"=>"947.11",
    #  "total_cost"=>947112}
    assert_equal expected_recommendation, recommendation.more_attributes
  end

  test 'region constraint on root ingredient' do
    @rails_app.preferred_region_area_constraint = PreferredRegionAreaConstraint.create(preferred_region_area: 'US')
    create(:amazon_provider)
    create(:google_provider)
    create(:azure_provider)

    recommendation = DeploymentRecommendation.construct(@rails_app)

    expected_resources = %w(A2 A3 A1).collect { |n|  Resource.find_by_name(n) }
    ingredient_ids = @rails_app.children.sort_by(&:id).map(&:id)
    resource_ids = expected_resources.collect(&:id)
    ingredients_hash = Hash[ingredient_ids.zip(resource_ids)]
    region_codes = expected_resources.collect(&:region_code)
    expected_recommendation = {
      'ingredients' => ingredients_hash,
      'regions' => region_codes,
      'vm_cost' => '475.42',
      'total_cost' => 475416
    }
    assert_equal expected_recommendation, recommendation.more_attributes
  end

  test 'hierarchical region constraint' do
    @rails_app.preferred_region_area_constraint = PreferredRegionAreaConstraint.create(preferred_region_area: 'US')
    lb = Ingredient.find_by_name('NGINX')
    lb.preferred_region_area_constraint = PreferredRegionAreaConstraint.create(preferred_region_area: 'EU')
    create(:amazon_provider)
    create(:google_provider)
    create(:azure_provider)

    recommendation = DeploymentRecommendation.construct(@rails_app)

    expected_resources = %w(A2 A3 t2.micro).collect { |n|  Resource.find_by_name(n) }
    ingredient_ids = @rails_app.children.sort_by(&:id).map(&:id)
    resource_ids = expected_resources.collect(&:id)
    ingredients_hash = Hash[ingredient_ids.zip(resource_ids)]
    region_codes = expected_resources.collect(&:region_code)
    expected_recommendation = {
        'ingredients' => ingredients_hash,
        'regions' => region_codes,
        'vm_cost' => '414.41',
        'total_cost' => 434408
    }
    assert_equal expected_recommendation, recommendation.more_attributes
  end

  test 'unsatisfiable constraint' do
    create(:amazon_provider)
    rc = @rails_app.children.first.ram_constraint
    rc.min_ram = 16_000_000
    rc.save!

    recommendation = DeploymentRecommendation.construct(@rails_app)
    # No instance available with more than 15GB RAM
    assert_equal 'unsatisfiable', recommendation.status
    assert_equal 'constraint forall(i in Ingredients)(ram[assignments[i]] >= min_ram[i]);', recommendation.more_attributes['unsatisfiable_message']
  end
end
