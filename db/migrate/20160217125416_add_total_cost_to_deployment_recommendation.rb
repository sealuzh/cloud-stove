class AddTotalCostToDeploymentRecommendation < ActiveRecord::Migration
  def change
    add_column :deployment_recommendations, :total_cost, :decimal
  end
end
