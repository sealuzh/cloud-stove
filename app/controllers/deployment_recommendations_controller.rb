class DeploymentRecommendationsController < ApplicationController

  def generate
    DeploymentRecommendation.compute_recommendation(SloSet.find(params['slo_set_id']))
    render :nothing => true
  end


end