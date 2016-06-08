class NoSuchIngredientValidator < ActiveModel::Validator
  def validate(record)
    if !Ingredient.exists?(record.target_id)
      record.errors[:no_such_target] = 'The specified target ingredient does not exist!'
    end
    if !Ingredient.exists?(record.source_id)
      record.errors[:no_such_source] = 'The specified source ingredient does not exist!'
    end
    if !Ingredient.exists?(record.ingredient_id)
      record.errors[:no_such_ingredient] = 'The specified ingredient does not exist!'
    end
  end
end