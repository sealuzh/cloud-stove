class IngredientCopyEngine

  def copy(original)
    base_copy(original)
  end

  def make_template(original)
    (!original.is_template && original.application_root?) ? base_copy(original, true, false) : NIL
  end

  def instantiate(original, new_user)
    (original.is_template && original.application_root?) ? base_copy(original, false, true, new_user) : NIL
  end


  private

    def base_copy(original, template=false, instance=false, new_user = original.user)
      # copies_hash: hash that maps ingredient ids (keys) of the original ingredients to the newly created copies (values)
      # root_copy: the root ingredient of the new (copied) hierarchy
      copies_hash, root_copy = deep_dup({},original, template, instance)

      # get all dependency constraints of the original root ingredient, to copy them onto the new structure
      dependency_constraints = original.all_dependency_constraints

      if original.parent
        # attach to parent of origin if there is any
        root_copy.parent = original.parent

        # if only a subtree is copied (e.g. the root_copy has a parent), there may be dependency constraints to ingredients that did not get copied
        # because they were outside the subtree being copied (e.g. they have no entry in the copies_hash)
        # then we use the original ingredient as source/target instead of the non-existing copy
        dependency_constraints.each do |dependency_constraint|
          d = DependencyConstraint.new
          d.source = (copies_hash[dependency_constraint.source.id]) ? copies_hash[dependency_constraint.source.id] : Ingredient.find(dependency_constraint.source.id)
          d.ingredient = (copies_hash[dependency_constraint.source.id]) ? copies_hash[dependency_constraint.source.id] : Ingredient.find(dependency_constraint.source.id)
          d.target = (copies_hash[dependency_constraint.target.id]) ? copies_hash[dependency_constraint.target.id] : Ingredient.find(dependency_constraint.target.id)
          d.save!
        end

      else
        dependency_constraints.each do |dependency_constraint|
          d = DependencyConstraint.new
          d.source = copies_hash[dependency_constraint.source.id]
          d.ingredient = copies_hash[dependency_constraint.source.id]
          d.target = copies_hash[dependency_constraint.target.id]
          d.save!
        end
      end
      root_copy.name = copy_ingredient_name(root_copy, template,instance)
      root_copy.assign_user!(new_user)
      root_copy.save!
      # Necessary to reflect the latest changes (e.g. from, `assign_user`) in the return value
      root_copy.reload
    end

    def deep_dup(copies_hash,current, template=false, instance=false)
      copy = current.dup
      copy.cpu_constraint = current.cpu_constraint.dup if current.cpu_constraint.present?
      copy.ram_constraint = current.ram_constraint.dup if current.ram_constraint.present?
      copy.preferred_region_area_constraint = current.preferred_region_area_constraint.dup if current.preferred_region_area_constraint.present?
      copy.provider_constraint = current.provider_constraint.dup if current.provider_constraint.present?
      copy.ram_workload = current.ram_workload.dup if current.ram_workload.present?
      copy.cpu_workload = current.cpu_workload.dup if current.cpu_workload.present?
      copy.scaling_workload = current.scaling_workload.dup if current.scaling_workload.present?
      copy.is_template = template
      copy.template = current if instance
      copies_hash[current.id] = copy

      current.children.each do |child|
        copies_hash.merge(deep_dup(copies_hash,child,template,instance)[0])
      end

      if !copies_hash.empty? && !current.parent.nil?
        if copies_hash[current.parent.id]
          copy.parent = copies_hash[current.parent.id]
        end
      end
      copy.save!

      return copies_hash,copy
    end

    def copy_ingredient_name(ingredient,template,instance)

      if template
        name = "[TEMPLATE] " + ingredient.name
        return name
      elsif instance
        name = "[INSTANCE OF] " + ingredient.name
        return name
      else
        num_copies = Ingredient.where(name: ingredient.name).length
        name = ingredient.name + " [v#{num_copies}]"
        return name
      end
    end
end
