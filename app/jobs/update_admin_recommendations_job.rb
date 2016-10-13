class UpdateAdminRecommendationsJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    RecommendationSeeds.update_admin_recommendations
  end
end
