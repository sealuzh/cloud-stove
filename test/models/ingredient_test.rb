require 'test_helper'

class IngredientTest < ActiveSupport::TestCase
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

  test 'ingredient template' do
    template = create(:ingredient)
    instance = create(:ingredient, template: template)

    assert_equal template, instance.template
    assert_equal instance, template.instances.first
  end
end
