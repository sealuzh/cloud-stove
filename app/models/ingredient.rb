class Ingredient < Base
  belongs_to :parent, class_name: "Ingredient"
  belongs_to :template, class_name: "Ingredient"
  has_many :constraints
end
