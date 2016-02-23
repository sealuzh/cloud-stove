class CloudApplication < Base
  ma_accessor :body
  belongs_to :blueprint
  has_many :concrete_components, dependent: :destroy
  accepts_nested_attributes_for :concrete_components, allow_destroy: true
  
  def deep_dup
    deep_copy = self.dup
    deep_copy.concrete_components = self.concrete_components.map(&:deep_dup)
    deep_copy
  end

  def provider_costs
    provider_costs = {}
    Provider.all.each do |provider|
      cost_sum = 0
      concrete_components.all.map{|c| cost_sum = c.slo_sets.first.deployment_recommendations.where(provider:provider.name).order('total_cost ASC').first.total_cost}
      provider_costs[provider.name] = cost_sum
    end
    provider_costs

  rescue
    return NIL
  end

end
