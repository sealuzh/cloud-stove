class DeploymentRecommendationsController < ApplicationController

  def provider_recommendations
    cloud_application = CloudApplication.find(params[:id])
    provider_name = params[:provider]
    @provider_recommendations = []
    cloud_application.concrete_components.map{|component| @provider_recommendations << [component.name, component.slo_sets.first.deployment_recommendations.where(provider: provider_name).order('total_cost ASC').first]}
    @cloud_application = cloud_application
    render 'provider_recommendations'
  end
end
