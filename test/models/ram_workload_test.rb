require 'test_helper'

class RamWorkloadTest < ActiveSupport::TestCase
  test 'min_ram' do
    ram_workload = RamWorkload.new(ram_mb_required: 2000, ram_mb_required_user_capacity: 100, ram_mb_growth_per_user: 0.5)
    assert_equal 2200, ram_workload.min_ram(400)
  end

  test 'min_ram with rounding up' do
    ram_workload = RamWorkload.new(ram_mb_required: 2000, ram_mb_required_user_capacity: 100, ram_mb_growth_per_user: 0.5)
    assert_equal 2200, ram_workload.min_ram(399)
  end

  test 'updating ram workload should delete all recommendations' do
    recommendation = create(:deployment_recommendation)
    rails_app = recommendation.ingredient
    ram_workload = rails_app.children.first.ram_workload
    ram_workload.update(ram_mb_required: 1234)
    assert_equal 0, rails_app.deployment_recommendations.count
  end
end
