class CreateWorkloads < ActiveRecord::Migration
  def change
    create_table :workloads do |t|
      t.integer :cpu_cores
      t.integer :ram_mb
      t.integer :baseline_num_users
      t.integer :requests_per_user_per_moth
      t.integer :request_size_kb
      t.references :ingredient, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
