require 'test_helper'

class IngredientCopyEngineTest < ActiveSupport::TestCase
  test 'application instance copy with single ingredient' do
    original = create(:ingredient)
    user_wl = create(:user_workload, ingredient: original)
    ram_constraint = create(:ram_constraint, ingredient: original)
    cpu_constraint = create(:cpu_constraint, ingredient: original)
    ram_wl = create(:ram_workload, ingredient: original)
    cpu_wl = create(:cpu_workload, ingredient: original)
    copy = original.copy

    # Basic copy
    assert copy.name.start_with?(original.name)
    assert_equal 0, copy.children.count

    # Constraints
    assert_equal ram_constraint.min_ram, copy.ram_constraint.min_ram
    assert_equal cpu_constraint.min_cpus, copy.cpu_constraint.min_cpus
    
    # Workloads
    # assert_equal cpu_wl.cspu_user_capacity, copy.cpu_workload.cspu_user_capacity
    # assert_equal ram_wl.ram_mb_required, copy.ram_workload.ram_mb_required
  end

  test 'application instance copy with 2 level children' do
    root = create(:ingredient)
    child_1 = create(:ingredient, parent: root)
    child_1_1 = create(:ingredient, parent: child_1)

    user_wl = create(:user_workload, ingredient: child_1_1)
    ram_constraint = create(:ram_constraint, ingredient: child_1_1)
    cpu_constraint = create(:cpu_constraint, ingredient: child_1_1)
    ram_wl = create(:ram_workload, ingredient: child_1_1)
    cpu_wl = create(:cpu_workload, ingredient: child_1_1)
    copy_root = root.copy
    copy_child_1_1 = copy_root.children.first.children.first

    # Basic copy
    assert copy_root.name.start_with?(root.name)
    assert_equal 1, copy_root.children.count

    # Constraints
    assert_equal ram_constraint.min_ram, copy_child_1_1.ram_constraint.min_ram
    assert_equal cpu_constraint.min_cpus, copy_child_1_1.cpu_constraint.min_cpus

    # Workloads
    # assert_equal cpu_wl.cspu_user_capacity, copy_child_1_1.cpu_workload.cspu_user_capacity
    # assert_equal ram_wl.ram_mb_required, copy_child_1_1.ram_workload.ram_mb_required
  end
end
