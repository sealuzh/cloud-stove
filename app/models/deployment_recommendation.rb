class DeploymentRecommendation < Base
  belongs_to :slo_set, autosave: true
  ma_accessor :resource_name
  ma_accessor :resource
  ma_accessor :num_instances
  ma_accessor :achieved_availability


  def self.compute_recommendation(slo_set)
    engine = RecommendationEngine.new
    engine.compute_recommendation(slo_set)
  end

  def self.compute_recommendations(cloud_application)
    engine = RecommendationEngine.new
    engine.compute_recommendations(cloud_application)
  end

end
