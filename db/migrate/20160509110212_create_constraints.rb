class CreateConstraints < ActiveRecord::Migration
  def change
    create_table :constraints do |t|
      t.references :ingredient, index: true, foreign_key: true
      t.text :more_attributes
      t.timestamps null: false
    end
  end
end
