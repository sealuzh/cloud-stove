class ComputeRecommendationsJobTest < ActiveJob::TestCase

  def setup
    @cloud_application = create(:cloud_application)
  end

  # Ensures that the job gets enqueued correctly
  test 'compute recommendations enqueueing' do

    assert_enqueued_jobs 0
    assert_performed_jobs 0

    assert_enqueued_with(job: ComputeRecommendationsJob, args: [@cloud_application]) do
      ComputeRecommendationsJob.perform_later @cloud_application
    end
    assert_enqueued_jobs 1
    assert_performed_jobs 0
  end
end
