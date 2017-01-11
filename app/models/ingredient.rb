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
  has_one :scaling_workload, class_name: 'ScalingWorkload', dependent: :destroy

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
  ## Scaling constraint
  has_one :scaling_constraint, class_name: 'ScalingConstraint', dependent: :destroy

  accepts_nested_attributes_for :constraints_as_source, allow_destroy: true
  accepts_nested_attributes_for :constraints, allow_destroy: true
  accepts_nested_attributes_for :cpu_constraint, allow_destroy: true
  accepts_nested_attributes_for :ram_constraint, allow_destroy: true
  accepts_nested_attributes_for :scaling_constraint, allow_destroy: true
  accepts_nested_attributes_for :preferred_region_area_constraint, allow_destroy: true
  accepts_nested_attributes_for :provider_constraint, allow_destroy: true

  def self.leafs
    Ingredient.select { |i| i.leaf? }
  end

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
    hash[:icon] = self.icon
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
    workloads[:scaling_workload] = self.scaling_workload.as_json if self.scaling_workload.present?
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

  def instantiate(new_user = self.user)
    engine = IngredientCopyEngine.new
    engine.instantiate(self, new_user)
  end

  def schedule_recommendation_jobs(num_users_list)
    fail 'Recommendations can only be generated for root ingredients!' unless self.application_root?
    ActiveRecord::Base.transaction do
      job = ConstructRecommendationsJob.perform_later(self, num_users_list)
      self.add_job(job.job_id)
      job
    end
  end

  def construct_recommendations(num_users_list, args = {perform_later: true})
    providers = self.provider_constraint.providers rescue [nil]
    num_users_list.each do |num_users|
      providers.each do |provider|
        recommendation = self.deployment_recommendations.create(
            num_simultaneous_users: num_users,
            status: DeploymentRecommendation::UNCONSTRUCTED,
            user: self.user
        )
        ActiveRecord::Base.transaction do
          update_constraints(num_users)
          recommendation.construct(provider)
        end
        if args[:perform_later]
          recommendation.schedule_evaluation
        else
          recommendation.evaluate
        end
      end
    end
  end

  def add_job(job_id)
    # Notice that the `more_attributes` serialization mechanism converts the set into an array
    ma['jobs'].present? ? ma['jobs'] = Set.new(ma['jobs']).add(job_id) : ma['jobs'] = Set.new([job_id])
    self.save!
  end

  def remove_job(job_id)
    self.more_attributes['jobs'].delete(job_id)
    self.save!
  end

  def jobs_completed?
    self.more_attributes['jobs'].size == 0 rescue true
  end

  def scaling_workload
    super || create_scaling_workload(scale_ingredient: true, user_id: user_id)
  end

  def cpu_workload
    super || create_cpu_workload(cspu_user_capacity: 1500, parallelism: 0.9, user_id: user_id)
  end

  def ram_workload
    super || create_ram_workload(ram_mb_required: 600, ram_mb_required_user_capacity: 200, ram_mb_growth_per_user: 0.3, user_id: user_id)
  end

  def update_constraints(num_users)
    all_leafs.each do |leaf|
      leaf.ram_workload.to_constraint(num_users)
      leaf.cpu_workload.to_constraint(num_users)
      leaf.scaling_workload.to_constraint(num_users)
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
    self.parent.nil?
  end

  def leaf?
    self.children.none?
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
    (self.scaling_workload.user = new_user; scaling_workload.save!) if self.scaling_workload.present?
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
