class TemplateInstantiationValidator < ActiveModel::Validator
  def validate(record)
    if record.template_id && !Ingredient.find(record.template_id).is_template?
      record.errors[:template] << 'Cannot instantiate non-template ingredient'
    end
  end
end
