class RecommendationEngine

  def compute_recommendation(slo_set)

    wanted_availability = slo_set.availability['$gte'].to_f

    Provider.all.each do |provider|

      # ensure availabilty is achieved
      n = number_of_instances(wanted_availability, provider.availability)
      achieved_availability = compute_availability(n, provider.availability)


      # save all recommendations that fulfill the rest of the Slos
      provider.resources.all.each do |resource|

        fulfills_cost, total_cost = cost_filer(n,resource,slo_set)
        if !fulfills_cost
          next
        end

        deployment_recommendation = DeploymentRecommendation.new
        deployment_recommendation.provider = provider.name
        deployment_recommendation.resource_name = resource.name
        deployment_recommendation.resource = resource.more_attributes
        deployment_recommendation.num_instances = n
        deployment_recommendation.slo_set = slo_set
        deployment_recommendation.total_cost = total_cost
        deployment_recommendation.achieved_availability = achieved_availability
        deployment_recommendation.save


      end

    end

  end

  private

  def cost_filer(num_instances, resource, slo_set)
    # if there is a cost slo in the set, compute the total cost and compare it
    if slo_set.costs

      total_cost = total_cost(num_instances, resource, slo_set.costs['interval'])

      if total_cost <= slo_set.costs['$lte'].to_f
        return true, total_cost
      else
        return false, total_cost
      end

    else #if there is no cost slo, assume cost slo fulfilled and return total cost
      return true, total_cost(num_instances,resource)
    end
  end

  def total_cost(num_instances, resource, cost_interval = 'month')
    if cost_interval == 'month'
      resource.price_per_month * num_instances
    elsif cost_interval == 'hour'
      resource.price_per_hour * num_instances
    end
  end

  # Computes the total availability that is achieved with num_instances
  # each having an availability of resource_availability
  def compute_availability(num_instances, resource_availability)
    1 - ((1 - resource_availability) ** num_instances)
  end


  # Compute how many instances are necessary to reach wanted_availability
  # if each instance has an SLA of instance_availability
  def number_of_instances(wanted_availability,instance_availability)
    if wanted_availability > instance_availability
      x = 1 - wanted_availability
      y = 1 - instance_availability
      Math.log(x,y).ceil
    else
      1
    end
  end

end