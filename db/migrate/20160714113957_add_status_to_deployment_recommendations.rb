class AddStatusToDeploymentRecommendations < ActiveRecord::Migration
  def change
    add_column :deployment_recommendations, :status, :string
  end
end
