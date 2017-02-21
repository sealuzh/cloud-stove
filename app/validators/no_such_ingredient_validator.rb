class NoSuchIngredientValidator < ActiveModel::Validator
  def validate(record)
    unless Ingredient.exists?(record.target_id)
      record.errors[:no_such_target] = 'The specified target ingredient does not exist!'
    end
  end
end
