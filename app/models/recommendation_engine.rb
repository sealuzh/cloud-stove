class RecommendationEngine


  # TODO: Add consistency guarantees across concreteComponents
  def compute_recommendations(cloud_application)
    cloud_application.concrete_components.each do |component|
      component.slo_sets.each do |slo_set|
        compute_recommendation(slo_set)
      end
    end
  end


  def compute_recommendation(slo_set)

    wanted_availability = slo_set.availability['$gte'].to_d

    Provider.all.each do |provider|

      # ensure availabilty is achieved
      n = number_of_instances(wanted_availability, provider.availability)
      achieved_availability = compute_availability(n, provider.availability)


      # save all recommendations that fulfill the rest of the Slos
      provider.resources.all.each do |resource|

        fulfills_cost, total_cost, cost_interval = cost_filer(n,resource,slo_set)
        if !fulfills_cost
          next
        end

        deployment_recommendation = DeploymentRecommendation.new
        deployment_recommendation.provider = provider.name
        deployment_recommendation.provider_id = provider.id
        deployment_recommendation.resource_name = resource.name
        deployment_recommendation.resource = resource.more_attributes
        deployment_recommendation.num_instances = n
        deployment_recommendation.slo_set = slo_set
        deployment_recommendation.total_cost = total_cost
        deployment_recommendation.cost_interval = cost_interval
        deployment_recommendation.achieved_availability = achieved_availability
        deployment_recommendation.save


      end

    end

  end

  ## Private helper functions

  private

  def cost_filer(num_instances, resource, slo_set)
    # if there is a cost slo in the set, compute the total cost and compare it
    if slo_set.costs

      total_cost, cost_interval = total_cost(num_instances, resource, slo_set.costs['interval'])

      if total_cost <= slo_set.costs['$lte'].to_d
        return true, total_cost, cost_interval
      else
        return false, total_cost, cost_interval
      end

    else #if there is no cost slo, assume cost slo fulfilled and return total cost
      cost, cost_interval = total_cost(num_instances,resource)
      return true, cost, cost_interval
    end
  end

  def total_cost(num_instances, resource, cost_interval = 'month')
    if cost_interval == 'month'
      return resource.price_per_month * num_instances, 'month'
    elsif cost_interval == 'hour'
      return resource.price_per_hour * num_instances, 'hour'
    end
  end

  # Computes the total availability that is achieved with num_instances
  # each having an availability of resource_availability
  def compute_availability(num_instances, resource_availability)
    (1 - ((1 - resource_availability) ** num_instances)).to_d
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