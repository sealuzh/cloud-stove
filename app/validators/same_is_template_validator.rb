class SameIsTemplateValidator < ActiveModel::Validator
  def validate(record)
    if record.parent && record.is_template? != record.parent.is_template?
      record.errors[:is_template] << 'Parent ingredient must also be ' + (record.is_template? ? 'a template' : 'an instance')
    end
  end
end
