class ConstructRecommendationsJob < ActiveJob::Base
  queue_as :default

  def perform(ingredient, users_list)
    ingredient.reload
    ingredient.construct_recommendations(users_list)
  ensure
    ingredient.remove_job(self.job_id)
  end
end
