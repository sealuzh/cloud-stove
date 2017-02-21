class RecommendationSeedsController < ApplicationController
  before_action :authenticate_admin!

  def update_admin_recommendations
    # Wait a couple of seconds to serve the current page first as immediate page reloads results in DB locking error.
    UpdateAdminRecommendationsJob.set(wait: 3.seconds).perform_later
    respond_to do |format|
      format.html { redirect_to :back, notice: 'A job for updating the admin deployment recommendations has been scheduled!' }
    end
  rescue => e
    respond_to do |format|
      format.html { redirect_to :back, error: "Error while scheduling admin deployment recommendation seeds: #{e.message}" }
    end
  end
end
