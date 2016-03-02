class ExtendApplicationDeploymentRecommendation < ActiveRecord::Migration
  def change
    #additions to ApplicationDeploymentRecommendation
    add_column :application_deployment_recommendations, :total_cost, :decimal
    add_reference :application_deployment_recommendations, :provider
    add_column :application_deployment_recommendations, :provider_name, :string

    #DeploymentRecommendation should be able to reference an ApplicationDeploymentRecommendation
    add_reference :deployment_recommendations, :application_deployment_recommendation

  end
end
