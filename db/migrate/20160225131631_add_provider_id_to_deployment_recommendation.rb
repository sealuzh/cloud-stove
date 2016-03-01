class AddProviderIdToDeploymentRecommendation < ActiveRecord::Migration
  def change
    add_reference :deployment_recommendations, :provider
  end
end
