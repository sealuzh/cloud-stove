class Ingredient < Base

  # Each ingredient can have a template that was used as a blueprint at instantiation
  belongs_to :parent, class_name: 'Ingredient'
  validates_with SameIsTemplateValidator
  validates_with NoCyclesValidator

  # Reverse relationship: each parent ingredient can have children ingredients
  has_many :children, class_name: 'Ingredient', foreign_key: 'parent_id', dependent: :destroy

  def all_leafs(leafs = [])
    children.each do |child|
      if child.children.any?
        leafs.push *child.all_leafs
      else
        leafs.push child
      end
    end
    leafs
  end

  # Each ingredient can have a parent that allows nesting composite ingredients
  belongs_to :template, class_name: 'Ingredient'
  validates_with TemplateInstantiationValidator

  # Reverse relationship: each template ingredient can have derived instance ingredients
  has_many :instances, class_name: 'Ingredient', foreign_key: 'template_id'

  has_one :deployment_recommendation

  # Associated generic constraints
  has_many :constraints, dependent: :destroy

  # Generic constraints
  has_many :constraints
  ## Dependency constraints
  has_many :dependency_constraints, class_name: 'DependencyConstraint'
  has_many :constraints_as_source, class_name: 'DependencyConstraint', foreign_key: 'source_id', dependent: :destroy
  has_many :constraints_as_target, class_name: 'DependencyConstraint', foreign_key: 'target_id', dependent: :destroy
  ## Ram constraints
  has_one :ram_constraint, class_name: 'RamConstraint', dependent: :destroy
  ## Cpu constraints
  has_one :cpu_constraint, class_name: 'CpuConstraint', dependent: :destroy

  accepts_nested_attributes_for :constraints_as_source, allow_destroy: true
  accepts_nested_attributes_for :constraints, allow_destroy: true
  accepts_nested_attributes_for :cpu_constraint, allow_destroy: true
  accepts_nested_attributes_for :ram_constraint, allow_destroy: true

  # traverses the ingredients subtree and collects all dependency constraints in it
  def all_dependency_constraints
    dependency_constraints_rec(self, {}).values
  end

  def is_root
    (self.parent.nil? && self.children.length != 0)
  end

  def as_json(options={})
    hash = {}
    hash[:id] = self.id
    hash[:name] = self.name
    hash[:body] = self.body
    hash[:parent_id] = self.parent.id unless self.parent.nil?
    hash[:template_id] = self.template.id unless self.template.nil?
    hash[:created_at] = self.created_at
    hash[:updated_at] = self.updated_at
    hash[:children] = self.children.collect {|c| c.as_json} unless options[:children] == false
    hash[:constraints] = self.constraints.collect {|c| c.as_json} unless options[:constraints] == false
    hash
  end

  def copy
    engine = IngredientCopyEngine.new
    engine.copy(self)
  end

  def make_template
    engine = IngredientCopyEngine.new
    engine.make_template(self)
  end

  def instantiate
    engine = IngredientCopyEngine.new
    engine.instantiate(self)
  end


  def schedule_recommendation_job
    ComputeRecommendationJob.perform_later(self)
  end

  private

  def deep_dup(copies_hash,current)
    copy = current.dup
    copy.cpu_constraint = current.cpu_constraint.dup unless current.cpu_constraint.nil?
    copy.ram_constraint = current.ram_constraint.dup unless current.ram_constraint.nil?
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

  # recursive postorder tree traversal method that returns a hash with all dependency constraints found in the subtree
  def dependency_constraints_rec(current_ingredient, constraint_hash)
      current_ingredient.children.all.each do |child|
        constraint_hash.merge(dependency_constraints_rec(child, constraint_hash))
      end

      current_ingredient.constraints_as_source.all.each do |constraint|
        constraint_hash[constraint.id] = constraint
      end
      current_ingredient.constraints_as_target.all.each do |constraint|
        constraint_hash[constraint.id] = constraint
      end

      constraint_hash
  end

end
