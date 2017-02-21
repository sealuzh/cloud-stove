class CpuWorkload < Workload
  belongs_to :ingredient
  belongs_to :user

  def to_constraint(num_users)
    self.ingredient.cpu_constraint.destroy if self.ingredient.cpu_constraint.present?
    self.ingredient.cpu_constraint = CpuConstraint.create(
      min_cpus: min_cpus(num_users)
    )
  end

  def min_cpus(num_users)
    (1 + [0, additional_cpus(num_users)].max)
  end

  def additional_cpus(num_users)
    (num_users - self.cspu_user_capacity) / (self.parallelism * self.cspu_user_capacity).ceil
  end

  def as_json(options={})
    hash = {}
    hash[:id] = self.id
    hash[:cspu_user_capacity] = self.cspu_user_capacity
    hash[:parallelism] = self.parallelism
    hash[:ingredient_id] = self.ingredient_id
    hash
  end
end
