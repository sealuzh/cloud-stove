require 'test_helper'

class ScalingWorkloadTest < ActiveSupport::TestCase
  test 'updating scaling workload should delete all recommendations' do
    recommendation = create(:deployment_recommendation)
    rails_app = recommendation.ingredient
    scaling_workload = rails_app.children.first.scaling_workload
    scaling_workload.update(scale_ingredient: false)
    assert_equal 0, rails_app.deployment_recommendations.count
  end
end
