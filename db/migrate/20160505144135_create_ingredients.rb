class CreateIngredients < ActiveRecord::Migration
  def change
    create_table :ingredients do |t|
      t.string :name
      t.text :body
      t.string :type
      t.text :more_attributes
      t.timestamps ull: false
    end
    add_reference :ingredients, :parent, references: :ingredients, index: true
    add_reference :ingredients, :template, references: :ingredients, index: true
  end
end
