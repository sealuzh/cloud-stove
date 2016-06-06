class AddIsTemplateToIngredients < ActiveRecord::Migration
  def change
    add_column :ingredients, :is_template, :boolean, default: false
    add_index :ingredients, :is_template
  end
end
