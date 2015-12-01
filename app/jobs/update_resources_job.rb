class UpdateResourcesJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    Provider.update_providers
  end
end
