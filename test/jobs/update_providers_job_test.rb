require 'test_helper'

class UpdateProvidersJobTest < ActiveJob::TestCase

  test 'provider update scheduling' do
    assert_enqueued_with(job: UpdateProvidersJob) do
      Provider.update_providers
    end

    clear_enqueued_jobs

    provider_updaters = ProviderUpdater.providers
    UpdateProvidersJob.perform_now
    assert_enqueued_jobs provider_updaters.size
    enqueued_jobs = queue_adapter.enqueued_jobs.map { |j| j[:job] }
    provider_updaters.each do |updater|
      assert_includes(enqueued_jobs, updater)
    end
  end


end
