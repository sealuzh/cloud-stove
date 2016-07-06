class ProviderConstraint < Constraint

  # We assume 'preferred_providers' in the db to a comma-separated string of provider names
  def provider_list
    self.preferred_providers.split(',').collect {|e| e.strip}
  end

  def as_json(options={})
    hash = super
    hash[:providers] = self.provider_list
    hash
  end
end