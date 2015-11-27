class CreateCloudApplications < ActiveRecord::Migration
  def change
    create_table :cloud_applications do |t|
      t.string :name
      t.text :more_attributes

      t.timestamps null: false
    end
  end
end
