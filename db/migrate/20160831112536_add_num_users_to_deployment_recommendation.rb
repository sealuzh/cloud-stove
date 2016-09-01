class AddNumUsersToDeploymentRecommendation < ActiveRecord::Migration
  def change
    add_column :deployment_recommendations, :num_simultaneous_users, :integer
  end
end
