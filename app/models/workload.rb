class Workload < ActiveRecord::Base
  self.abstract_class = true

  before_update do
    self.ingredient.application_root.deployment_recommendations.delete_all
  end

  def to_constraint(num_users)
    raise NotImplementedError
  end
end
