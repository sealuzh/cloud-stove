class Workload < ActiveRecord::Base
  belongs_to :ingredient

  def as_json(options={})
    hash = {}
    hash[:id] = self.id
    hash[:baseline_num_users] = self.baseline_num_users
    hash[:requests_per_user] = self.requests_per_user
    hash[:request_size_kb] = self.request_size_kb
    hash[:ram_mb] = self.ram_mb
    hash[:cpu_cores] = self.cpu_cores
    hash[:ingredient_id] = self.ingredient_id
    hash
  end

end
