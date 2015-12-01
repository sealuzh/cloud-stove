class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.string :name
      t.text :more_attributes

      t.timestamps null: false
    end
  end
end
