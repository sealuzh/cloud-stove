class IngredientCopyEngine
  # Copies an ingredient tree or subtree
  # The subtree copy attaches a copy of a subtree to its parent and
  # duplicates its dependency constraints by remapping source/target
  # outside the subtree to its original
  def copy(original)
    num_copies = Ingredient.where(user: original.user, name: original.name).count + 1
    deep_dup(original).set_name_suffix!("[V#{num_copies}] ")
  end

  # Instantiates an ingredient application template into an ingredient application
  def instantiate(original, new_user)
    ensure_application_root(original)
    ensure_template(original)
    deep_dup(original, instance: true, user: new_user).set_name_prefix!('[INSTANCE OF] ')
  end

  # Creates a template from an ingredient application
  def make_template(original)
    ensure_application_root(original)
    ensure_non_template(original)
    deep_dup(original, template: true).set_name_prefix!('[TEMPLATE] ')
  end

  private

    def ensure_application_root(original)
      fail 'Ingredient must be an application root.' unless original.application_root?
    end

    def ensure_template(original)
      fail 'Ingredient must be a template.' unless original.is_template
    end

    def ensure_non_template(original)
      fail 'Ingredient must be a non-template.' if original.is_template
    end

    # @param `opts` [Hash] copy option (defaults)
    # * `template` [Boolean] whether the copied ingredients  (original.is_template)
    # * `instance` [Boolean] whether to instantiate by setting the template relationship (false)
    # * `user` [String] the user the new copy belongs to (original.user)
    def deep_dup(original, opts = {})
      defaults = { template: original.is_template, instance: false, user: original.user }
      opts = defaults.merge(opts)

      copies = deep_dup_rec(original, opts)
      copy_root = copies.values.first
      dependency_constraints = original.all_dependency_constraints
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
