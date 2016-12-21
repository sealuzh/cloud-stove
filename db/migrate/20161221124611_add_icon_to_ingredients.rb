class AddIconToIngredients < ActiveRecord::Migration
  def change
    add_column :ingredients, :icon, :string, default: 'server'
    Rake::Task['update:icon'].invoke
  end
end
