class DeploymentRecommendationsController < ApplicationController

  before_action :authenticate_user!

  def show
    @recommendation = current_user.deployment_recommendations.find_by(ingredient_id: params[:ingredient_id])

    respond_to do |format|
      format.html
      format.json {render json: @recommendation, status: :ok}
    end

  end

  def index
    @recommendations = current_user.deployment_recommendations.where(ingredient_id: params[:ingredient_id])

    respond_to do |format|
      format.html
      format.json {render json: @recommendations, status: :ok}
    end

  end

  def has_recommendations
    root_ingredient = current_user.ingredients.find(params[:ingredient_id]).application_root
    @has_recommendations = current_user.deployment_recommendations.where(ingredient_id: root_ingredient.id).any?

    respond_to do |format|
      format.html
      format.json { render json: @has_recommendations, status: :ok}
    end
  end

  def trigger
    ingredient = current_user.ingredients.find_by_id(params[:ingredient_id])

    if !ingredient
      respond_to do |format|
        format.html
        format.json { render json: 'Ingredient does not exist!', status: :not_found}
      end
    elsif !ingredient.application_root?
      respond_to do |format|
       format.html
       format.json { render json: 'Ingredient must be a root ingredient!', status: :forbidden}
      end
    else
      job_id = ingredient.schedule_recommendation_job.job_id
      respond_to do |format|
        format.html {redirect_to :back, notice: 'DeploymentRecommendation has been scheduled!' }
        format.json { render json: {:job_id => job_id}, status: :ok}
      end
    end
  end

end