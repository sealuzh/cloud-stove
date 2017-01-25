class DependencyConstraint < Constraint
  belongs_to :ingredient
  belongs_to :user
  belongs_to :source, class_name: 'Ingredient'
  belongs_to :target, class_name: 'Ingredient'

  validates_with NoSuchIngredientValidator

  # in the form, only source and target can be set, this ensures that the :ingredient association is also set correctly
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
