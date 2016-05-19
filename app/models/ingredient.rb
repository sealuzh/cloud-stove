class Ingredient < Base
  # Each ingredient can have a template that was used as a blueprint at instantiation
  belongs_to :parent, class_name: 'Ingredient'
  # Reverse relationship: each parent ingredient can have children ingredients
  has_many :children, class_name: 'Ingredient', foreign_key: 'parent_id'

  # Each ingredient can have a parent that allows nesting composite ingredients
  belongs_to :template, class_name: 'Ingredient'
  validates_with TemplateInstantiationValidator
  # Reverse relationship: each template ingredient can have derived instance ingredients
  has_many :instances, class_name: 'Ingredient', foreign_key: 'template_id'

  # Associated generic constraints
  has_many :constraints

  # Associated dependency constraints
  has_many :constraints_as_source, class_name: 'DependencyConstraint',
           foreign_key: 'source_id'
  has_many :constraints_as_target, class_name: 'DependencyConstraint',
           foreign_key: 'target_id'
end
