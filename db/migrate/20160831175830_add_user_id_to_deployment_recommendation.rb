class AddUserIdToDeploymentRecommendation < ActiveRecord::Migration
  def change
    add_column :deployment_recommendations, :user_id, :integer
  end
end
