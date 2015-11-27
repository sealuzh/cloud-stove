class CreateComponents < ActiveRecord::Migration
  def change
    create_table :components do |t|
      t.string :name
      t.string :component_type
      t.text :more_attributes
      t.references :cloud_application

      t.timestamps null: false
    end
  end
end
