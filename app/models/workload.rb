class Workload < ActiveRecord::Base
  belongs_to :ingredient

  def as_json(options={})
    hash = {}
    hash[:id] = self.id
    hash[:baseline_num_users] = self.baseline_num_users
    hash[:requests_per_user] = self.requests_per_user
    hash[:request_size_kb] = self.request_size_kb
    hash[:ram_level] = self.ram_level
    hash[:cpu_level] = self.cpu_level
    hash[:ingredient_id] = self.ingredient_id
    hash
  end

end
