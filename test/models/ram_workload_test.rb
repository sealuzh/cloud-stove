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
end
