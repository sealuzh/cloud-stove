class Ingredient < Base
  #each ingredient can have a template and has a parent that allows nesting composite ingredients
  belongs_to :parent, class_name: "Ingredient"
  belongs_to :template, class_name: "Ingredient"

  #the reverse relations to the ones above
  has_many :children, class_name: "Ingredient", foreign_key: "parent_id"
  has_one :instance, class_name: "Ingredient", foreign_key: "template_id"

  has_many :constraints

end
