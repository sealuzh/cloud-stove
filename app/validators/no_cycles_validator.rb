class NoCyclesValidator < ActiveModel::Validator
  def validate(record)
    id = record.id
    current = record
    while ! current.parent.nil? && !current.id.nil? && !id.nil? do
      if current.parent.id == id
        record.errors[:nocycle] << 'Creating cyclic ingredient hierarchies is not allowed!'
        break
      end
      current = current.parent
    end
  end
end