class DeploymentRecommendation < ActiveRecord::Base
  belongs_to :slo_set
  ma_accessor :resource
  ma_accessor :num_instances


  def self.compute_recommendation(slo_sets)

    Provider.all.each do |provider|

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
      end
    end
end
