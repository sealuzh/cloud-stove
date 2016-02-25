class AddProviderIdToDeploymentRecommendation < ActiveRecord::Migration
  def change
    add_column :deployment_recommendations, :provider_id, :number
  end
end
