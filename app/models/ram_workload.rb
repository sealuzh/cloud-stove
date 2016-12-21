class RamWorkload < ActiveRecord::Base
  belongs_to :ingredient
  belongs_to :user

  before_update do
    self.ingredient.application_root.deployment_recommendations.delete_all
  end

  def to_constraint(num_users)
    self.ingredient.ram_constraint.destroy if self.ingredient.ram_constraint.present?
    self.ingredient.ram_constraint = RamConstraint.create(
      min_ram: min_ram(num_users)
    )
  end

  def min_ram(num_users)
    self.ram_mb_required + (num_users * self.ram_mb_growth_per_user).ceil
  end

  def as_json(options={})
    hash = {}
    hash[:id] = self.id
    hash[:ram_mb_required] = self.ram_mb_required
    hash[:ram_mb_required_user_capacity] = self.ram_mb_required_user_capacity
    hash[:ram_mb_growth_per_user] = self.ram_mb_growth_per_user
    hash[:ingredient_id] = self.ingredient_id
    hash
  end
end
