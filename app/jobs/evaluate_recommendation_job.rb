class EvaluateRecommendationJob < ActiveJob::Base
  queue_as :default

  def perform(recommendation)
    recommendation.evaluate
  end
end
