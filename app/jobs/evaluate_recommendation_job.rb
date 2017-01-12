class EvaluateRecommendationJob < ActiveJob::Base
  queue_as :default

  def perform(recommendation)
    ingredient = recommendation.ingredient
    recommendation.evaluate
  ensure
    ingredient.remove_job(self.job_id)
  end
end
