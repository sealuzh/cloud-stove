class ComputeRecommendationJob < ActiveJob::Base
  queue_as :default

  def perform(ingredient)
    if ingredient.provider_constraint.present?
      ingredient.provider_constraint.provider_list.each do |provider_name|
        provider_id = Provider.find_by_name(provider_name)
        DeploymentRecommendation.construct(ingredient, provider_id)
      end
    else
      DeploymentRecommendation.construct(ingredient)
    end
  end
end
