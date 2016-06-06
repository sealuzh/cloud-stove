class Ingredient < Base

  # Each ingredient can have a template that was used as a blueprint at instantiation
  belongs_to :parent, class_name: 'Ingredient'
  validates_with SameIsTemplateValidator
  validates_with NoCyclesValidator

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

  #TODO: add validation to avoid being your own parent

  accepts_nested_attributes_for :constraints_as_source, allow_destroy: true
  accepts_nested_attributes_for :constraints, allow_destroy: true

  def all_dependency_constraints
    return dependency_constraints(self,{}).values
  end

  def is_root
    return (self.parent.nil? && self.children.length != 0)
  end

  private
    def dependency_constraints(current_ingredient,constraint_hash)
      current_ingredient.children.all.each do |child|
        constraint_hash.merge(dependency_constraints(child,constraint_hash))
      end

      current_ingredient.constraints_as_source.all.each do |constraint|
        constraint_hash[constraint.id] = constraint
      end
      current_ingredient.constraints_as_target.all.each do |constraint|
        constraint_hash[constraint.id] = constraint
      end

      return constraint_hash
    end

end
