class CpuWorkload < ActiveRecord::Base
  belongs_to :ingredient

  def as_json(options={})
    hash = {}
    hash[:id] = self.id
    hash[:cspu_user_capacity] = self.cspu_user_capacity
    hash[:cspu_slope] = self.cspu_slope
    hash[:ingredient_id] = self.ingredient_id
    hash
  end

  def to_constraint()

  end

end
