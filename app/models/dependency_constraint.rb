class DependencyConstraint < Constraint
  belongs_to :source, class_name: 'Ingredient'
  belongs_to :target, class_name: 'Ingredient'
end
