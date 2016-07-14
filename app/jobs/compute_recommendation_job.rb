class ComputeRecommendationJob < ActiveJob::Base
  queue_as :default

  def perform(ingredient, provider_id)
    DeploymentRecommendation.construct(ingredient, provider_id)
  end
end
