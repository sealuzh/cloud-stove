require 'test_helper'

class IngredientTest < ActiveSupport::TestCase
  test 'childless ingredient is application root' do
    ingredient = create(:ingredient)
    assert ingredient.application_root?
  end

  test 'instantiation' do
    ingredient = create(:ingredient, name: 'Sample Ingredient', body: '# Sample Ingredient')

    assert ingredient.valid?
    assert_equal 'Sample Ingredient', ingredient.name
    assert_equal '# Sample Ingredient', ingredient.body
  end

  test 'hierarchical composition' do
    parent = create(:ingredient)
    child1 = create(:ingredient, parent: parent)
    child2 = create(:ingredient, parent: parent)

    assert_equal parent, child1.parent
    assert_equal [child1, child2], parent.children
  end

  test 'all_leafs' do
    root_parent = create(:ingredient)
    child = create(:ingredient, parent: root_parent)
    child_parent = create(:ingredient, parent: root_parent)
    children = create_list(:ingredient, 2, parent: child_parent)

    assert_equal ([child] + children), root_parent.all_leafs
  end

  test 'hierarchical traversal for region constraint' do
    root = create(:ingredient, name: 'root')
    root.constraints << PreferredRegionAreaConstraint.create(preferred_region_area: 'EU')
    level1_1 = create(:ingredient, parent: root)
    level1_1.constraints << PreferredRegionAreaConstraint.create(preferred_region_area: 'US')
    level1_2 = create(:ingredient, parent: root)
    level2_1 = create(:ingredient, parent: level1_1)
    level2_1.constraints << PreferredRegionAreaConstraint.create(preferred_region_area: 'ASIA')
    level2_2 = create(:ingredient, parent: level1_1)

    expected_regions = %w(ASIA US EU)
    assert_equal expected_regions, root.region_constraints
  end

  test 'ingredient template' do
    template = create(:ingredient, :template)
    instance = create(:ingredient, template: template)

    assert template.is_template?
    assert !instance.is_template?
    assert_equal template, instance.template
    assert_equal instance, template.instances.first
  end

  test 'prohibit to instantiate non-templates' do
    non_template = create(:ingredient)
    instance = build(:ingredient, template: non_template)

    assert instance.invalid?
    assert_equal 'Cannot instantiate non-template ingredient', instance.errors[:template].first
  end

  test 'prohibit mixing templates with non-templates' do
    parent_template = create(:ingredient, :template)
    child_instance = build(:ingredient, parent: parent_template)

    assert child_instance.invalid?
    assert_equal 'Parent ingredient must also be an instance', child_instance.errors[:is_template].first
  end
end
