require 'test_helper'

class DeploymentRecommendationTest < ActiveSupport::TestCase
  SEEDS_ROOT = Rails.root + 'db/seeds/'
  def require_seed(name)
    require (SEEDS_ROOT + name)
  end

  test 'generate deployment recommendation' do
    Ingredient.find_or_create_by(name: 'Multitier Architecture')
    require_seed 'ingredient_instance_rails_app'
    rails_app = Ingredient.find_by_name('Rails Application with PostgreSQL Backend')
    create(:amazon_provider)
    create(:google_provider)

    recommendation = DeploymentRecommendation.construct(rails_app)

    c3_2xlarge = Resource.find_by_name('c3.2xlarge')
    t2_micro = Resource.find_by_name('t2.micro')
    ingredient_ids = rails_app.children.sort_by(&:id).map(&:id)
    resource_ids = [c3_2xlarge.id, c3_2xlarge.id, t2_micro.id, c3_2xlarge.id]
    # Corresponds to: ["c3.2xlarge", "c3.2xlarge", "t2.micro", "c3.2xlarge"]
    ingredients_hash = Hash[ingredient_ids.zip(resource_ids)]
    expected_recommendation =  {
      'ingredients' => ingredients_hash,
      'vm_cost' => '947.11',
      'total_cost' => 947112
    }
    # Example JSON: {"ingredients":{"3":145,"4":145,"5":144,"6":145},"vm_cost":"947.11","total_cost":947112}
    assert_equal expected_recommendation, recommendation.more_attributes
  end

  # test 'unsatisfiable constraint' do
  #   skip 'TODO: write a test with an unsatisfiable constraint property'
  # end
end
