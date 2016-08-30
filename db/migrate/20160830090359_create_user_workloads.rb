class CreateUserWorkloads < ActiveRecord::Migration
  def change
    create_table :user_workloads do |t|
      t.integer :num_simultaneous_users
      t.references :ingredient, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
