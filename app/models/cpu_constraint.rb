class CpuConstraint < Constraint

  belongs_to :user

  def as_json(options={})
    hash = super
    hash[:min_cpus] = self.min_cpus
    hash
  end
end
