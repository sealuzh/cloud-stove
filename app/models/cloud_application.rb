class CloudApplication < Base
  ma_accessor :body
  belongs_to :blueprint
  has_many :concrete_components, dependent: :destroy
  has_many :application_deployment_recommendations, dependent: :destroy
  accepts_nested_attributes_for :concrete_components, allow_destroy: true
  
  def self.new_from_blueprint(blueprint)
    blueprint = Blueprint.find(blueprint) unless blueprint.is_a? Blueprint
    CloudApplication.new do |cloud_application|
      cloud_application.name = blueprint.name
      cloud_application.body = blueprint.body
      blueprint.components.each do |component|
        cloud_application.concrete_components.build(
          name: component.name,
          more_attributes: component.more_attributes,
          component: component
        )
      end
    end
  end
  
  def deep_dup
    deep_copy = self.dup
    deep_copy.concrete_components = self.concrete_components.map(&:deep_dup)
    deep_copy
  end


  def provider_costs
    provider_costs = []

    ApplicationDeploymentRecommendation.where(cloud_application_id: id).each do |app_deployment_recommendation|
      provider_costs << {:provider_id => app_deployment_recommendation.provider_id, :provider_name => app_deployment_recommendation.provider_name, :cost => app_deployment_recommendation.total_cost}
    end

    return provider_costs

  rescue
    return NIL

  end

end
