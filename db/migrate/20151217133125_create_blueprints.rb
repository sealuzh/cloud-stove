class CreateBlueprints < ActiveRecord::Migration
  def change
    create_table :blueprints do |t|
      t.string :name
      t.text :more_attributes

      t.timestamps null: false
    end
  end
end
