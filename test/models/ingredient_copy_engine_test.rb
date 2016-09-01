require 'test_helper'

class IngredientCopyEngineTest < ActiveSupport::TestCase
  test 'application instance copy with single ingredient' do
    original = create(:ingredient)
    create(:user_workload, ingredient: original)
    create(:preferred_region_area_constraint, ingredient: original)
    create(:ram_constraint, ingredient: original)
    create(:cpu_constraint, ingredient: original)
    create(:ram_workload, ingredient: original)
    create(:cpu_workload, ingredient: original)
    copy = original.copy

    assert_basic_copy(original, copy)
    assert_equal original.user_workload.num_simultaneous_users, copy.user_workload.num_simultaneous_users
    assert_constraint_copy(original, copy)
    assert_workload_copy(original, copy)
  end

  test 'application instance copy with 2 level children' do
    root = create(:ingredient)
    child_1 = create(:ingredient, parent: root)
    child_1_1 = create(:ingredient, parent: child_1)

    create(:user_workload, ingredient: child_1_1)
    create(:preferred_region_area_constraint, ingredient: child_1_1)
    create(:ram_constraint, ingredient: child_1_1)
    create(:cpu_constraint, ingredient: child_1_1)
    create(:ram_workload, ingredient: child_1_1)
    create(:cpu_workload, ingredient: child_1_1)
    copy_root = root.copy
    copy_child_1_1 = copy_root.children.first.children.first

    assert_basic_copy(root, copy_root)
    assert_basic_copy(child_1_1, copy_child_1_1)
    assert_constraint_copy(child_1_1, copy_child_1_1)
    assert_workload_copy(child_1_1, copy_child_1_1)
  end

  def assert_basic_copy(original, copy)
    assert copy.name.start_with?(original.name)
    assert_equal original.children.count, copy.children.count
  end

  def assert_constraint_copy(original, copy)
    assert_equal original.ram_constraint.min_ram, copy.ram_constraint.min_ram
    assert_equal original.cpu_constraint.min_cpus, copy.cpu_constraint.min_cpus
    assert_equal original.preferred_region_area_constraint.preferred_region_area, copy.preferred_region_area_constraint.preferred_region_area
  end

  def assert_workload_copy(original, copy)
    assert_equal original.ram_workload.ram_mb_required, copy.ram_workload.ram_mb_required
    assert_equal original.cpu_workload.cspu_user_capacity, copy.cpu_workload.cspu_user_capacity
  end
end
