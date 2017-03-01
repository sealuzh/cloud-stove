require 'test_helper'

class CpuWorkloadTest < ActiveSupport::TestCase
  test 'min_cpu for num_simultaneous_users > cspu_user_capacity' do
    cpu_workload = CpuWorkload.new(cspu_user_capacity: 200, parallelism: 0.5)
    assert_equal 3, cpu_workload.min_cpus(400)
  end

  test 'min_cpu for num_simultaneous_users < cspu_user_capacity' do
    cpu_workload = CpuWorkload.new(cspu_user_capacity: 200, parallelism: 0.5)
    assert_equal 1, cpu_workload.min_cpus(100)
  end

  test 'updating cpu workload should delete all recommendations' do
    recommendation = create(:deployment_recommendation)
    rails_app = recommendation.ingredient
    cpu_workload = rails_app.children.first.cpu_workload
    cpu_workload.update(cspu_user_capacity: 1234)
    assert_equal 0, rails_app.deployment_recommendations.count
  end
end
