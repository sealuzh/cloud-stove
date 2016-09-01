class UserWorkload < ActiveRecord::Base
  belongs_to :ingredient

  def as_json(options={})
    hash = {}
    hash[:id] = self.id
    hash[:num_simultaneous_users] = self.num_simultaneous_users
    hash[:ingredient_id] = self.ingredient_id
    hash
  end
end
