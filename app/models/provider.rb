class Provider < Base
  has_many :resources
  
  def self.update_providers
    ProviderUpdater.providers.map(&:perform)
  end
end
