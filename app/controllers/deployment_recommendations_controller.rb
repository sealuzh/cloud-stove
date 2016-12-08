class DeploymentRecommendationsController < ApplicationController
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


  def destroy
    recommendation = current_user.deployment_recommendations.find(params[:recommendation_id])
    if recommendation.present?
      recommendation.delete
      respond_to do |format|
        format.json {render json:  'Recommendation deleted successfully!', status: :ok}
      end
    else
      respond_to do |format|
        format.json {render json:  'Recommendation could not be found!', status: :not_found}
      end
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

  def trigger_range
    ingredient = current_user.ingredients.find(params[:ingredient_id])
    min = params[:min].to_i || 100
    max = params[:max].to_i || 500
    step = params[:step].to_i || 50
    range = (min..max).step(step).to_a
    job_ids = ingredient.schedule_recommendation_jobs(range)

    # TODO: Handle error case
    respond_to do |format|
      format.html { redirect_to :back, notice: 'DeploymentRecommendation has been scheduled!' }
      format.json { render json: {job_ids: job_ids}, status: :ok}
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
