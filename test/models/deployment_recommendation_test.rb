require 'test_helper'

class DeploymentRecommendationTest < ActiveSupport::TestCase
  SEEDS_ROOT = Rails.root + 'db/seeds/'
  def load_seed(name)
    load ("#{SEEDS_ROOT}#{name}.rb")
  end

  test 'generate deployment recommendation' do
    Ingredient.find_or_create_by(name: 'Multitier Architecture')
    load_seed 'ingredient_instance_rails_app'
    rails_app = Ingredient.find_by_name('Rails Application with PostgreSQL Backend')
    build(:user_workload, ingredient: rails_app)
    rails_app.user_workload = UserWorkload.new(ingredient: rails_app, num_simultaneous_users: 200)
    create(:amazon_provider)
    create(:google_provider)

    recommendation = DeploymentRecommendation.construct(rails_app)

    expected_resources = %w(c3.2xlarge c3.2xlarge t2.micro c3.2xlarge).collect { |n|  Resource.find_by_name(n) }
    ingredient_ids = rails_app.children.sort_by(&:id).map(&:id)
    resource_ids = expected_resources.collect(&:id)
    ingredients_hash = Hash[ingredient_ids.zip(resource_ids)]
    region_codes = expected_resources.collect(&:region_code)
    expected_recommendation =  {
      'ingredients' => ingredients_hash,
      'regions' => region_codes,
      'vm_cost' => '947.11',
      'total_cost' => 947112
    }
    # Example JSON: {"ingredients":{"3":145,"4":145,"5":144,"6":145},
    # "regions":[-1468347494899780561,-1468347494899780561,-1468347494899780561,-1468347494899780561],
    # "vm_cost":"947.11","total_cost":947112}
    assert_equal expected_recommendation, recommendation.more_attributes
  end

  test 'region constraint on root ingredient' do
    Ingredient.find_or_create_by(name: 'Multitier Architecture')
    load_seed 'ingredient_instance_rails_app'
    rails_app = Ingredient.find_by_name('Rails Application with PostgreSQL Backend')
    build(:user_workload, ingredient: rails_app)
    rails_app.constraints << PreferredRegionAreaConstraint.create(preferred_region_area: 'US')
    create(:amazon_provider)
    create(:google_provider)
    create(:azure_provider)

    recommendation = DeploymentRecommendation.construct(rails_app)

    expected_resources = %w(A2 A3 A1 A2).collect { |n|  Resource.find_by_name(n) }
    ingredient_ids = rails_app.children.sort_by(&:id).map(&:id)
    resource_ids = expected_resources.collect(&:id)
    ingredients_hash = Hash[ingredient_ids.zip(resource_ids)]
    region_codes = expected_resources.collect(&:region_code)
    expected_recommendation = {
      'ingredients' => ingredients_hash,
      'regions' => region_codes,
      'vm_cost' => '627.19',
      'total_cost' => 627192
    }
    assert_equal expected_recommendation, recommendation.more_attributes
  end

  test 'hierarchical region constraint' do
    Ingredient.find_or_create_by(name: 'Multitier Architecture')
    load_seed 'ingredient_instance_rails_app'
    rails_app = Ingredient.find_by_name('Rails Application with PostgreSQL Backend')
    build(:user_workload, ingredient: rails_app)
    rails_app.constraints << PreferredRegionAreaConstraint.create(preferred_region_area: 'US')
    lb = Ingredient.find_by_name('NGINX')
    lb.constraints << PreferredRegionAreaConstraint.create(preferred_region_area: 'EU')
    create(:amazon_provider)
    create(:google_provider)
    create(:azure_provider)

    recommendation = DeploymentRecommendation.construct(rails_app)

    expected_resources = %w(A2 A3 t2.micro A2).collect { |n|  Resource.find_by_name(n) }
    ingredient_ids = rails_app.children.sort_by(&:id).map(&:id)
    resource_ids = expected_resources.collect(&:id)
    ingredients_hash = Hash[ingredient_ids.zip(resource_ids)]
    region_codes = expected_resources.collect(&:region_code)
    expected_recommendation = {
        'ingredients' => ingredients_hash,
        'regions' => region_codes,
        'vm_cost' => '566.18',
        'total_cost' => 606184
    }
    assert_equal expected_recommendation, recommendation.more_attributes
  end

  test 'unsatisfiable constraint' do
    Ingredient.find_or_create_by(name: 'Multitier Architecture')
    load_seed 'ingredient_instance_rails_app'
    rails_app = Ingredient.find_by_name('Rails Application with PostgreSQL Backend')
    build(:user_workload, ingredient: rails_app)
    create(:google_provider)

    recommendation = DeploymentRecommendation.construct(rails_app)
    # Google provider factories have no instance available to satisfy the 4G RAM constraint
    assert_equal 'unsatisfiable', recommendation.status
  end
end
