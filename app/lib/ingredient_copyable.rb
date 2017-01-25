module IngredientCopyable
  # Copies an ingredient tree or subtree
  # The subtree copy attaches a copy of a subtree to its parent and
  # duplicates its dependency constraints by remapping source/target
  # outside the subtree to its original
  def copy
    num_copies = Ingredient.where(user: self.user, name: self.name).count + 1
    deep_dup.set_name_suffix!("[V#{num_copies}] ")
  end

  # Instantiates an ingredient application template into an ingredient application
  def instantiate(new_user = self.user)
    ensure_application_root
    ensure_template
    deep_dup(instance: true, user: new_user).set_name_prefix!('[INSTANCE OF] ')
  end

  # Creates a template from an ingredient application
  def make_template
    ensure_application_root
    ensure_non_template
    deep_dup(template: true).set_name_prefix!('[TEMPLATE] ')
  end

  private

  def ensure_application_root
    fail 'Ingredient must be an application root.' unless self.application_root?
  end

  def ensure_template
    fail 'Ingredient must be a template.' unless self.is_template
  end

  def ensure_non_template
    fail 'Ingredient must be a non-template.' if self.is_template
  end

  # @param `opts` [Hash] copy option (defaults)
  # * `template` [Boolean] whether the copied ingredients  (self.is_template)
  # * `instance` [Boolean] whether to instantiate by setting the template relationship (false)
  # * `user` [String] the user the new copy belongs to (self.user)
  def deep_dup(opts = {})
    defaults = { template: self.is_template, instance: false, user: self.user }
    opts = defaults.merge(opts)

    copies = deep_dup_rec(self, opts)
    copy_root = copies.values.first
    dependency_constraints = self.all_dependency_constraints
    dependency_constraints.each do |dependency_constraint|
      DependencyConstraint.create(
          ingredient: copies[dependency_constraint.ingredient] || dependency_constraint.ingredient,
          source: copies[dependency_constraint.source] || dependency_constraint.source,
          target: copies[dependency_constraint.target] || dependency_constraint.target
      )
    end

    copy_root.assign_user!(opts[:user])
    copy_root.save!
    # Necessary to reflect the latest changes (e.g. from, `assign_user`) in the return value
    copy_root.reload
  end

  # @param `copies` [Hash] the mapping from original ingredients to newly created copies: [original] => [copy]
  def deep_dup_rec(original, opts, copies = {})
    copy = original.dup
    copy.cpu_constraint = original.cpu_constraint.dup if original.cpu_constraint.present?
    copy.ram_constraint = original.ram_constraint.dup if original.ram_constraint.present?
    copy.preferred_region_area_constraint = original.preferred_region_area_constraint.dup if original.preferred_region_area_constraint.present?
    copy.provider_constraint = original.provider_constraint.dup if original.provider_constraint.present?
    copy.ram_workload = original.ram_workload.dup if original.ram_workload.present?
    copy.cpu_workload = original.cpu_workload.dup if original.cpu_workload.present?
    copy.scaling_workload = original.scaling_workload.dup if original.scaling_workload.present?
    copy.is_template = opts[:template]
    copy.template = original if opts[:instance]
    # Remap `parent` association if existing for copy
    if copies[original.parent]
      copy.parent = copies[original.parent]
    elsif original.parent
      copy.parent = original.parent
    else
      # application root
    end
    copy.save!

    copies[original] = copy
    original.children.each do |child|
      copies.merge(deep_dup_rec(child, opts, copies))
    end
    copies
  end
end
