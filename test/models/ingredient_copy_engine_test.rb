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

    assert_basic_copy(original, copy)
    assert_constraint_copy(original, copy)
    
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

    assert_basic_copy(root, copy_root)
    assert_basic_copy(child_1_1, copy_child_1_1)
    assert_constraint_copy(child_1_1, copy_child_1_1)

    # TODO: impl. workload copy
    # assert_workload_copy(original, copy)
  end

  def assert_basic_copy(original, copy)
    assert copy.name.start_with?(original.name)
    assert_equal original.children.count, copy.children.count
  end

  def assert_constraint_copy(original, copy)
    assert_equal original.ram_constraint.min_ram, copy.ram_constraint.min_ram
    assert_equal original.cpu_constraint.min_cpus, copy.cpu_constraint.min_cpus
    # TODO: impl. region area copy
    # assert_equal original.preferred_region_area_constraint.preferred_region_area, copy.preferred_region_area_constraint.preferred_region_area
  end

  def assert_workload_copy(original, copy)
    assert_equal original.cpu_workload.cspu_user_capacity, copy.cpu_workload.cspu_user_capacity
    assert_equal original.ram_workload.ram_mb_required, copy.ram_workload.ram_mb_required
  end
end
