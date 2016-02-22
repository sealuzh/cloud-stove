class UpdateProvidersJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    ProviderUpdater.update_providers
  end
end
