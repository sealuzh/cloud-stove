class CreateComponents < ActiveRecord::Migration
  def change
    create_table :components do |t|
      t.string :name
      t.string :ctype
      t.text :cattributes
      t.references :cloud_application

      t.timestamps null: false
    end
  end
end
