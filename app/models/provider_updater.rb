class ProviderUpdater  
  class Error < StandardError; end
  
  def self.providers
    load_providers
    descendants
  end
  
  def self.update_providers
    providers.map(&:perform)
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