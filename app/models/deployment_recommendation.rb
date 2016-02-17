class DeploymentRecommendation < Base
  belongs_to :slo_set
  ma_accessor :provider
  ma_accessor :resource_name
  ma_accessor :resource
  ma_accessor :num_instances
  ma_accessor :achieved_availability


  def self.compute_recommendation(slo_set)
    engine = RecommendationEngine.new
    engine.compute_recommendation(slo_set)
  end

end
