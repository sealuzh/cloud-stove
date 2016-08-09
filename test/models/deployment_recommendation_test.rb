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
    create(:amazon_provider)
    create(:google_provider)

    recommendation = DeploymentRecommendation.construct(rails_app)

    c3_2xlarge = Resource.find_by_name('c3.2xlarge')
    t2_micro = Resource.find_by_name('t2.micro')
    ingredient_ids = rails_app.children.sort_by(&:id).map(&:id)
    resource_ids = [c3_2xlarge.id, c3_2xlarge.id, t2_micro.id, c3_2xlarge.id]
    ingredients_hash = Hash[ingredient_ids.zip(resource_ids)]
    expected_recommendation =  {
      'ingredients' => ingredients_hash,
      'regions' => [c3_2xlarge.region_code, c3_2xlarge.region_code, t2_micro.region_code, c3_2xlarge.region_code],
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
    rails_app.constraints << PreferredRegionAreaConstraint.create(preferred_region_area: 'US')
    create(:amazon_provider)
    create(:google_provider)
    create(:azure_provider)

    recommendation = DeploymentRecommendation.construct(rails_app)

    expected_resources = %w(A2 A3 A1 A2).collect { |n|  Resource.find_by_name(n) }
    ingredient_ids = rails_app.children.sort_by(&:id).map(&:id)
    resource_ids = expected_resources.collect(&:id)
    ingredients_hash = Hash[ingredient_ids.zip(resource_ids)]
    expected_recommendation = {
      'ingredients' => ingredients_hash,
      'regions' => expected_resources.collect(&:region_code),
      'vm_cost' => '627.19',
      'total_cost' => 627192
    }
    assert_equal expected_recommendation, recommendation.more_attributes
  end

  # test 'unsatisfiable constraint' do
  #   skip 'TODO: write a test with an unsatisfiable constraint property'
  # end
end
