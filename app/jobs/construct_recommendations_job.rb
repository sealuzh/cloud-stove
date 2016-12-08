class ConstructRecommendationsJob < ActiveJob::Base
  queue_as :default

  def perform(ingredient, users_list)
    ingredient.construct_recommendations(users_list)
  end
end
