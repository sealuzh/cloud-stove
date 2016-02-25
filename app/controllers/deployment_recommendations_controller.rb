class DeploymentRecommendationsController < ApplicationController

  def provider_recommendations
    cloud_application = CloudApplication.find(params[:id])
    @provider_recommendations = []
    cloud_application.concrete_components.map{|component| @provider_recommendations << [component.name, component.slo_sets.first.deployment_recommendations.where(provider_id: params[:provider_id]).order('total_cost ASC').first]}
    @cloud_application = cloud_application
    render 'provider_recommendations'
  end
end
