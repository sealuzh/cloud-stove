module IngredientsHelper

  def is_root(ingredient)
    return (ingredient.parent.nil? && ingredient.children.length != 0)
  end

end
