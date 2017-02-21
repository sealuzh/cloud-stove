class ProviderConstraint < Constraint
  # `preferred_providers` are stored in the DB as comma-separated strings of provider names
  # Example: `"Amazon,Google"`
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
