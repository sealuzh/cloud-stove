class AddProviderToDeploymentRecommendation < ActiveRecord::Migration
  def change
    add_column :deployment_recommendations, :provider, :string
  end
end
