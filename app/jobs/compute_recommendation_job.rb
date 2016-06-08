class ComputeRecommendationJob < ActiveJob::Base
  queue_as :default

  def perform(ingredient)
    DeploymentRecommendation.construct(ingredient)
  end
end
