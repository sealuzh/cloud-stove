class CpuWorkload < ActiveRecord::Base
  belongs_to :ingredient

  def as_json(options={})
    hash = {}
    hash[:id] = self.id
    hash[:cspu_user_capacity] = self.cspu_user_capacity
    hash[:parallelism] = self.parallelism
    hash[:ingredient_id] = self.ingredient_id
    hash
  end

  def to_constraint
    self.ingredient.cpu_constraint.destroy if self.ingredient.cpu_constraint.present?    
    self.ingredient.cpu_constraint = CpuConstraint.create(
      min_cpus: min_cpus(self.ingredient.num_simultaneous_users)
    )
  end

  def min_cpus(num_simultaneous_users)
    (1 + [0, additional_cpus(num_simultaneous_users)].max)
  end

  def additional_cpus(num_simultaneous_users)
    (num_simultaneous_users - self.cspu_user_capacity) / (self.parallelism * self.cspu_user_capacity).ceil
  end
end
