class CreateConcreteComponents < ActiveRecord::Migration
  def change
    create_table :concrete_components do |t|
      t.string :name
      t.text :more_attributes, default: "{}", null: false
      t.references :component, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
