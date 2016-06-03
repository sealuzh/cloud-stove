class DependencyConstraint < Constraint
  belongs_to :ingredient
  belongs_to :source, class_name: 'Ingredient'
  belongs_to :target, class_name: 'Ingredient'
  before_save :attach_source_ingredient


  private
    def attach_source_ingredient
      self.ingredient = self.source
    end
end
