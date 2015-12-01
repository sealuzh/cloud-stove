class ProviderUpdater  
  def self.providers
    load_providers
    descendants
  end
  
  def self.perform
    new().perform
  end
  
  private
  def self.load_providers
    Dir[Rails.root + 'app/provider_updaters/*.rb'].each do |updater|
      require updater
    end
  end
  
  def logger
    Rails.logger
  end
end