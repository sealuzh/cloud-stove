class DeploymentRecommendationsController < ApplicationController

  def show
    @recommendation = DeploymentRecommendation.find_by(ingredient_id: params[:ingredient_id])

    respond_to do |format|
      format.html
      format.json {render json: @recommendation, status: :ok}
    end

  end


  def trigger
    ingredient = Ingredient.find_by_id(params[:ingredient_id])

    if !ingredient
      respond_to do |format|
        format.html
        format.json { render json: 'Ingredient does not exist!', status: :not_found}
      end
    elsif !ingredient.is_root
      respond_to do |format|
       format.html
       format.json { render json: 'Ingredient must be a root ingredient!', status: :forbidden}
      end
    else
      ingredient.schedule_recommendation_job
      respond_to do |format|
        format.html {redirect_to :back, notice: 'DeploymentRecommendation has been scheduled!' }
        format.json { render json: 'Recommendation was successfully scheduled!', status: :ok}
      end
    end
  end

end