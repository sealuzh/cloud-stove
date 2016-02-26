class ComputeRecommendationsJob < ActiveJob::Base
  queue_as :default

  def perform(cloud_application)
    DeploymentRecommendation.transaction do
      #first delete existing recommendations for that app if any
      DeploymentRecommendation.delete_for_application(cloud_application)

      #compute new recommendations
      DeploymentRecommendation.compute_for_application(cloud_application)
    end
  end



end