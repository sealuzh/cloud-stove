class ProviderConstraint < Constraint
  # We assume 'preferred_providers' in the db to a comma-separated string of provider names
  def provider_names
    self.preferred_providers.split(',').collect {|e| e.strip}
  end

  def providers
    self.provider_names.map { |name| Provider.find_by_name(name) }
  end

  def as_json(options={})
    hash = super
    hash[:preferred_providers] = self.provider_names
    hash
  end
end
