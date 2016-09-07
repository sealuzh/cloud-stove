class RamConstraint < Constraint
  def as_json(options={})
    hash = super
    hash[:min_ram] = self.min_ram
    hash
  end
end
