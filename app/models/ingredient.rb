class Ingredient < Base
  #each ingredient can have a template and has a parent that allows nesting composite ingredients
  belongs_to :parent, class_name: "Ingredient"
  belongs_to :template, class_name: "Ingredient"

  #the reverse relations to the ones above
  has_many :children, class_name: "Ingredient", foreign_key: "parent_id"
  has_many :instances, class_name: "Ingredient", foreign_key: "template_id"

  has_many :constraints

  has_many :constraints_as_source, class_name: 'DependencyConstraint', foreign_key: 'source_id'
  has_many :constraints_as_target, class_name: 'DependencyConstraint', foreign_key: 'target_id'
end
