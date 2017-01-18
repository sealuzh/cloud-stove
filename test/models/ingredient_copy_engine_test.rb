require 'test_helper'

class IngredientCopyEngineTest < ActiveSupport::TestCase
  test 'application instance copy with single ingredient' do
    original = create(:ingredient)
    create(:preferred_region_area_constraint, ingredient: original)
    create(:ram_constraint, ingredient: original)
    create(:cpu_constraint, ingredient: original)
    create(:ram_workload, ingredient: original)
    create(:cpu_workload, ingredient: original)
    copy = original.copy

    assert_basic_copy(original, copy)
    assert_constraint_copy(original, copy)
    assert_workload_copy(original, copy)
  end

  test 'application instance copy with 2 level children' do
    user = create(:user)
    root = create(:ingredient, user: user)
    child_1 = create(:ingredient, user: user, parent: root)
    child_1_1 = create(:ingredient, user: user, parent: child_1)
    child_2 = create(:ingredient, user: user, parent: root)

    create(:dependency_constraint, source: child_1_1, target: child_2)
    create(:preferred_region_area_constraint, ingredient: child_1_1)
    create(:ram_constraint, ingredient: child_1_1)
    create(:cpu_constraint, ingredient: child_1_1)
    create(:ram_workload, ingredient: child_1_1)
    create(:cpu_workload, ingredient: child_1_1)
    copy_root = root.copy
    copy_child_1_1 = copy_root.children.first.children.first
    copy_child_2 = copy_root.children.last

    assert_basic_copy(root, copy_root)
    assert_basic_copy(child_1_1, copy_child_1_1)
    assert_constraint_copy(child_1_1, copy_child_1_1)
    assert_workload_copy(child_1_1, copy_child_1_1)
    # Dependency Constraint
    refute_empty copy_child_1_1.dependency_constraints
    assert_equal copy_child_2, copy_child_1_1.dependency_constraints.first.target
    assert_equal root.user, copy_child_1_1.dependency_constraints.first.user
  end

  test 'instantiate single ingredient' do
    template = create(:ingredient, :template)
    create(:preferred_region_area_constraint, ingredient: template)
    create(:ram_constraint, ingredient: template)
    create(:cpu_constraint, ingredient: template)
    create(:ram_workload, ingredient: template)
    create(:cpu_workload, ingredient: template)
    new_user = create(:user)

    instance = template.instantiate(new_user)

    assert_equal new_user, instance.user
    assert_equal template, instance.template
    assert_constraint_copy(template, instance, new_user)
    assert_workload_copy(template, instance, new_user)
  end

  def assert_basic_copy(original, copy, user=original.user)
    assert copy.name.start_with?(original.name)
    assert_equal original.children.count, copy.children.count
    assert_equal user, copy.user
  end

  def assert_constraint_copy(original, copy, user=original.user)
    assert_equal original.ram_constraint.min_ram, copy.ram_constraint.min_ram
    assert_equal user, copy.ram_constraint.user
    assert_equal original.cpu_constraint.min_cpus, copy.cpu_constraint.min_cpus
    assert_equal user, copy.cpu_constraint.user
    assert_equal original.preferred_region_area_constraint.preferred_region_area, copy.preferred_region_area_constraint.preferred_region_area
    assert_equal user, copy.preferred_region_area_constraint.user
  end

  def assert_workload_copy(original, copy, user=original.user)
    assert_equal original.ram_workload.ram_mb_required, copy.ram_workload.ram_mb_required
    assert_equal user, copy.ram_workload.user
    assert_equal original.cpu_workload.cspu_user_capacity, copy.cpu_workload.cspu_user_capacity
    # Lookup via `CpuWorkload` checks whether the changes are actually saved to the db!
    assert_equal user, CpuWorkload.find(copy.cpu_workload.id).user
  end
end
