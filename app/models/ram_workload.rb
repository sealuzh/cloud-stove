class RamWorkload < ActiveRecord::Base
  belongs_to :ingredient

  def as_json(options={})
    hash = {}
    hash[:id] = self.id
    hash[:ram_mb_required] = self.ram_mb_required
    hash[:ram_mb_required_user_capacity] = self.ram_mb_required_user_capacity
    hash[:ram_mb_growth_per_user] = self.ram_mb_growth_per_user
    hash[:ingredient_id] = self.ingredient_id
    hash
  end

  def to_constraint
    self.ingredient.ram_constraint.destroy if self.ingredient.ram_constraint.present?
    self.ingredient.ram_constraint = RamConstraint.create(
      min_ram: self.ram_mb_required + num_simultaneous_users * ram_mb_growth_per_user
    )
  end

  def num_simultaneous_users
    self.ingredient.num_simultaneous_users
  end
end
