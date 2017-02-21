class DependencyConstraint < Constraint
  belongs_to :ingredient
  belongs_to :user
  belongs_to :source, class_name: 'Ingredient'
  belongs_to :target, class_name: 'Ingredient'

  validates_with NoSuchIngredientValidator

  # Ensures that the `ingredient` association is set correctly because
  # the UI form only sets source and target
  before_save :attach_source_ingredient

  def as_json(options={})
    hash = super
    hash[:ingredient_id] = self.ingredient.id
    hash[:target_id] = self.target.id
    hash[:source_id] = self.source.id
    hash
  end

  private

    def attach_source_ingredient
      self.ingredient = self.source
    end
end
