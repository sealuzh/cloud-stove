class ScalingWorkload < ActiveRecord::Base
  belongs_to :ingredient
  belongs_to :user

  before_update do
    self.ingredient.application_root.deployment_recommendations.delete_all
  end

  def to_constraint(num_users)
    self.ingredient.scaling_constraint.destroy if self.ingredient.scaling_constraint.present?
    self.ingredient.scaling_constraint = ScalingConstraint.create(
      max_num_instances: scale_ingredient ? 0 : 1
    )
  end

  def as_json(options={})
    hash = {}
    hash[:id] = self.id
    hash[:scale_ingredient] = self.scale_ingredient
    hash[:ingredient_id] = self.ingredient_id
    hash
  end
end
