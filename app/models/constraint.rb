class Constraint < Base
  belongs_to :ingredient

  def as_json(options={})
    hash = {}
    hash[:id] = self.id
    hash[:type] = (self.type.nil? ? 'Constraint' : self.type)
    hash[:created_at] = self.created_at
    hash[:updated_at] = self.updated_at
    hash
  end
end
