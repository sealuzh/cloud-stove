class Workload < ActiveRecord::Base
  belongs_to :ingredient

  def as_json(options={})
    hash = {}
    hash[:id] = self.id
    hash[:visits_per_month] = self.visits_per_month
    hash[:requests_per_visit] = self.requests_per_visit
    hash[:request_size_kb] = self.request_size_kb
    hash[:ram_level] = self.ram_level
    hash[:cpu_level] = self.cpu_level
    hash[:ingredient_id] = self.ingredient_id
    hash
  end

end
