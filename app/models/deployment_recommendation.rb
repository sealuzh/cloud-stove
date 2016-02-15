class DeploymentRecommendation < Base
  belongs_to :slo_set
  ma_accessor :provider
  ma_accessor :resource_name
  ma_accessor :resource
  ma_accessor :num_instances


  def self.compute_recommendation(slo_set)

    # assuming the data structure of SloSet as in
    # https://github.com/inz/cloud-stove/pull/14#issuecomment-183431312

    wanted_availability = slo_set.availability['$gte'].to_f
    cost_value = slo_set.costs['$lte'].to_f
    cost_interval = slo_set.costs['interval']

    Provider.all.each do |provider|

      n = self.number_of_instances(wanted_availability, provider.availability)

      provider.resources.all.each do |resource|

        # check if current resource fulfills cost restrictions
        if (cost_interval == 'month' && (resource.price_per_month * n) <= cost_value) ||
            (cost_interval == 'hour' && (resource.price_per_hour * n) <= cost_value)

          deployment_recommendation = DeploymentRecommendation.new
          deployment_recommendation.provider = provider.name
          deployment_recommendation.resource_name = resource.name
          deployment_recommendation.resource = resource.more_attributes
          deployment_recommendation.num_instances = n
          deployment_recommendation.slo_set = slo_set
          deployment_recommendation.save!

        end

      end

    end

  end

  private
    # Compute how many instances are necessary to reach wanted_availability
    # if each instance has an SLA of instance_availability
    def self.number_of_instances(wanted_availability,instance_availability)

      # Rationale behind the formula used here:
      # The probability that the component is available (wanted_availability), is equal to the complement of the
      # probability that no instances of the component are available.
      # The probability that none of the instances are available is: (1 - instance_availability)^n
      # where n is the number of instances. Hence, the complement is: 1 - (1 - instance_availability)^n
      # This leads to:
      #
      # wanted_availability = 1 - (1 - instance_availability)^n
      #
      # Which can be formulated to
      #
      # 1 - wanted_availability = (1 - instance_availability)^n
      #
      # And hence, the number of instances necessary (n) is:
      #
      # n = log(1-wanted_availability,1-instance_availability)

      if wanted_availability > instance_availability
        x = 1 - wanted_availability
        y = 1 - instance_availability
        Math.log(x,y).ceil
      else
        1
      end
    end
end
