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

    expected_recommendation = JSON.parse '{"resources":["c3.2xlarge", "c3.2xlarge", "t2.micro", "c3.2xlarge"], "vm_cost":"947.11", "total_cost":947112}'
    assert_equal expected_recommendation, recommendation.more_attributes
  end

  # test 'unsatisfiable constraint' do
  #   skip 'TODO: write a test with an unsatisfiable constraint property'
  # end
end
