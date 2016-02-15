class DeploymentRecommendation < Base
  belongs_to :slo_set
  ma_accessor :provider
  ma_accessor :resource_name
  ma_accessor :resource
  ma_accessor :num_instances
  ma_accessor :total_cost
  ma_accessor :achieved_availability


  def self.compute_recommendation(slo_set)

    # assuming the data structure of SloSet as in
    # https://github.com/inz/cloud-stove/pull/14#issuecomment-183431312

    wanted_availability = slo_set.availability['$gte'].to_f
    cost_value = slo_set.costs['$lte'].to_f
    cost_interval = slo_set.costs['interval']

    Provider.all.each do |provider|

      n = self.number_of_instances(wanted_availability, provider.availability)
      achieved_availability = self.compute_availability(n, provider.availability)

      provider.resources.all.each do |resource|

        total_cost = total_cost(n,resource,cost_interval)

        if total_cost <= cost_value

          DeploymentRecommendation.create(
              provider: provider.name,
              resource_name: resource.name,
              resource: resource.more_attributes,
              num_instances: n,
              slo_set: slo_set,
              total_cost: total_cost,
              achieved_availability: achieved_availability
          )

        end

      end

    end

  end

  private

    def self.total_cost(num_instances, resource, cost_interval)
      if cost_interval == 'month'
        resource.price_per_month * num_instances
      elsif cost_interval == 'hour'
        resource.price_per_hour * num_instances
      end
    end


    def self.compute_availability(num_instances, resource_availability)
      1 - ((1 - resource_availability) ** num_instances)
    end


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
