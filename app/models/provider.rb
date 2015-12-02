class Provider < Base
  has_many :resources
  
  def self.update_providers
    ProviderUpdater.update_providers
  end
end
