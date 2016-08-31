class AddUserIdToIngredients < ActiveRecord::Migration
  def change
    add_column :ingredients, :user_id, :integer
  end
end
