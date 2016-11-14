class ScalingConstraint < Constraint
  def as_json(options={})
    hash = super
    hash[:max_num_instances] = self.max_num_instances
    hash
  end
end
