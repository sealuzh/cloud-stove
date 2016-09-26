namespace :jobs do
  desc 'Update providers inline.'
  task update_providers: :environment do
    Rails.application.config.active_job.queue_adapter = :inline
    ProviderUpdater.update_providers
  end

  desc 'Update providers asynchronously.'
  task update_providers_async: :environment do
    Provider.update_providers
  end
end
