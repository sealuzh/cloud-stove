class Constraint < Base
  belongs_to :ingredient

  def as_json(options={})
    hash = {}
    hash[:id] = self.id
    hash[:type] = (self.type.nil? ? 'Constraint' : self.type)
    hash
  end
end
