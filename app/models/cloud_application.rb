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

  # def provider_costs
  #   provider_costs = {}
  #   Provider.all.each do |provider|
  #     cost_sum = 0
  #     concrete_components.all.map{|c| cost_sum = c.slo_sets.first.deployment_recommendations.where(provider:provider.name).order('total_cost ASC').first.total_cost}
  #     provider_costs[provider.name] = cost_sum
  #   end
  #   provider_costs
  # rescue
  #   return NIL
  # end


  def provider_costs
    Base.connection.execute(provider_costs_query)
  end


  private

  def provider_costs_query
    "SELECT provider_id, provider_name, SUM(cost) AS cost
    FROM
      (
      SELECT slo_set_id, component_id, provider_id, provider_name, MIN(total_cost) AS cost
      FROM
        (
        SELECT s.id AS slo_set_id, c.id AS component_id, c.cloud_application_id AS app_id, p.id AS provider_id, p.name AS provider_name, d.total_cost
        FROM
        concrete_components AS c JOIN slo_sets AS s ON c.id = s.concrete_component_id JOIN deployment_recommendations AS d ON s.id = d.slo_set_id JOIN providers AS p ON d.provider_id = p.id
        WHERE c.cloud_application_id = #{id} AND s.id IN

          (
          SELECT id FROM slo_sets WHERE slo_sets.concrete_component_id = c.id LIMIT 1
          )
        )

      GROUP BY slo_set_id, component_id, provider_id, provider_name
      )

    GROUP BY provider_id, provider_name"
  end
end
