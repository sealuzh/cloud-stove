class DeploymentRecommendation < Base
  belongs_to :slo_set, autosave: true
  belongs_to :application_deployment_recommendation, autosave: true
  ma_accessor :resource_name
  ma_accessor :resource
  ma_accessor :num_instances
  ma_accessor :achieved_availability
  ma_accessor :cost_interval


  def self.compute_for_application(cloud_application)
    engine = RecommendationEngine.new
    engine.compute_recommendations(cloud_application)
  end

  def self.delete_for_application(cloud_application)
    cloud_application.concrete_components.all.each do |component|
      component.slo_sets.all.each do |slo_set|
        DeploymentRecommendation.where(slo_set_id:slo_set.id).delete_all
      end
    end
  end

end
