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

  accepts_nested_attributes_for :constraints_as_source, allow_destroy: true
  accepts_nested_attributes_for :constraints, allow_destroy: true

  # traverses the ingredients subtree and collects all dependency constraints in it
  def all_dependency_constraints
    return dependency_constraints(self,{}).values
  end

  def is_root
    return (self.parent.nil? && self.children.length != 0)
  end

  def as_json(options={})
    hash = {}
    hash[:id] = self.id
    hash[:name] = self.name
    hash[:body] = self.body
    hash[:children] = self.children.collect {|c| c.as_json}
    hash[:constraints] = self.constraints.collect {|c| c.as_json}
    hash
  end

  def copy
    copies_hash, root_copy = deep_dup({},self)

    dependency_constraints = all_dependency_constraints

    dependency_constraints.each do |dependency_constraint|
      d = DependencyConstraint.new
      d.source = copies_hash[dependency_constraint.source.id]
      d.ingredient = copies_hash[dependency_constraint.source.id]
      d.target = copies_hash[dependency_constraint.target.id]
      d.save!
    end
    return root_copy
  end

  private

  def deep_dup(copies_hash,current)
    copy = current.dup
    copies_hash[current.id] = copy

    current.children.each do |child|
      copies_hash.merge(deep_dup(copies_hash,child)[0])
    end

    if !copies_hash.empty? && !current.parent.nil?
      if copies_hash[current.parent.id]
        copy.parent = copies_hash[current.parent.id]
      end
    end

    copy.save!

    return copies_hash,copy
  end

  # recursive postorder tree traversal method that returns a hash with all constraints found
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
