class Ingredient < Base
  belongs_to :user

  # Each ingredient can have a template that was used as a blueprint at instantiation
  belongs_to :parent, class_name: 'Ingredient'
  validates_with SameIsTemplateValidator
  validates_with NoCyclesValidator

  # Reverse relationship: each parent ingredient can have children ingredients
  has_many :children, class_name: 'Ingredient', foreign_key: 'parent_id', dependent: :destroy

  # NOTICE: MUST ensure same traversal order than `region_constraints_rec`
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

  has_many :deployment_recommendations, dependent: :destroy

  # Workloads
  has_one :cpu_workload, class_name: 'CpuWorkload', dependent: :destroy
  has_one :ram_workload, class_name: 'RamWorkload', dependent: :destroy
  has_one :user_workload, class_name: 'UserWorkload', dependent: :destroy

  # Associated generic constraints
  has_many :constraints, dependent: :destroy

  # Generic constraints
  has_many :constraints, dependent: :destroy
  ## Dependency constraints
  has_many :dependency_constraints, class_name: 'DependencyConstraint', dependent: :destroy
  has_many :constraints_as_source, class_name: 'DependencyConstraint', foreign_key: 'source_id', dependent: :destroy
  has_many :constraints_as_target, class_name: 'DependencyConstraint', foreign_key: 'target_id', dependent: :destroy
  ## Ram constraints
  has_one :ram_constraint, class_name: 'RamConstraint', dependent: :destroy
  ## Cpu constraints
  has_one :cpu_constraint, class_name: 'CpuConstraint', dependent: :destroy
  ## Preferred region constraints
  has_one :preferred_region_area_constraint, class_name: 'PreferredRegionAreaConstraint', dependent: :destroy
  ## Provider constraints
  has_one :provider_constraint, class_name: 'ProviderConstraint', dependent: :destroy

  accepts_nested_attributes_for :constraints_as_source, allow_destroy: true
  accepts_nested_attributes_for :constraints, allow_destroy: true
  accepts_nested_attributes_for :cpu_constraint, allow_destroy: true
  accepts_nested_attributes_for :ram_constraint, allow_destroy: true
  accepts_nested_attributes_for :preferred_region_area_constraint, allow_destroy: true
  accepts_nested_attributes_for :provider_constraint, allow_destroy: true


  # traverses the ingredients subtree and collects all dependency constraints in it
  def all_dependency_constraints
    dependency_constraints_rec(self, {}).values
  end

  # Lists all region areas present in the model
  def preferred_region_areas
    region_constraints.uniq
  end

  # Lists the region area for each leaf ingredient
  def region_constraints
    current_constraint = current_region(self, 'EU')
    region_constraints_rec(self, [], current_constraint)
  end

  # NOTICE: MUST ensure same traversal order than `all_leafs`
  def region_constraints_rec(current_ingredient, constraints, current_constraint)
    current_ingredient.children.each do |child|
      new_current_constraint = current_region(child, current_constraint)
      if child.children.any?
        child.region_constraints_rec(child, constraints, new_current_constraint)
      else
        constraints.push(new_current_constraint)
      end
    end
    constraints
  end

  def current_region(current_ingredient, current_constraint)
    if current_ingredient.preferred_region_area_constraint.present?
      current_ingredient.preferred_region_area_constraint.preferred_region_area
    else
      current_constraint
    end
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
    hash[:workloads] = workload_jsons unless options[:workloads] == false || workload_jsons.empty?
    hash
  end

  def workload_jsons
    workloads = {}
    workloads[:cpu_workload] = self.cpu_workload.as_json if self.cpu_workload.present?
    workloads[:ram_workload] = self.ram_workload.as_json if self.ram_workload.present?
    workloads[:user_workload] = self.user_workload.as_json if self.user_workload.present?
    workloads
  end

  def copy
    engine = IngredientCopyEngine.new
    engine.copy(self)
  end

  def make_template
    engine = IngredientCopyEngine.new
    engine.make_template(self)
  end

  def instantiate(new_user)
    engine = IngredientCopyEngine.new
    engine.instantiate(self, new_user)
  end

  def schedule_recommendation_job(perform_later = true)
    update_constraints
    preferred_providers = self.provider_constraint.provider_list rescue [nil]
    jobs = []
    preferred_providers.each do |provider_name|
      provider_id = Provider.find_by_name(provider_name)
      if perform_later
        jobs << ComputeRecommendationJob.perform_later(self, provider_id)
      else
        DeploymentRecommendation.construct(self, provider_id)
      end
    end
    # TODO: Adjust API to return a list of job ids for each job
    jobs.last
  end

  def update_constraints
    all_leafs.each do |leaf|
      leaf.ram_workload.to_constraint
      leaf.cpu_workload.to_constraint
    end
  rescue => e
    raise 'Missing a workload definition for a leaf ingredient. ' + e.message
  end

  # Returns the root ingredient in the application hierarchy
  def application_root
    if application_root?
      self
    else
      self.parent.application_root
    end
  end

  def application_root?
    (self.parent.nil? && self.children.count > 0)
  end

  def num_simultaneous_users
    application_root.user_workload.num_simultaneous_users
  rescue => e
    raise 'User workload not specified for application root. ' + e.message
  end

  def assign_user!(new_user)
    self.user = new_user
    self.children.each do |child|
      child.assign_user!(new_user)
      child.save!
    end
    self.assign_user_to_attachments!(new_user)
    self.save!
  end

  def assign_user_to_attachments!(new_user)
    (self.user_workload.user = new_user; user_workload.save!) if self.user_workload.present?
    (self.ram_workload.user = new_user; ram_workload.save!) if self.ram_workload.present?
    (self.cpu_workload.user = new_user; cpu_workload.save!) if self.cpu_workload.present?
    self.constraints.each do |constraint|
      constraint.user = new_user
      constraint.save!
    end
    self.deployment_recommendations.each do |recommendation|
      recommendation.user = new_user
      recommendation.save!
    end
    self.save!
  end

  private

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
