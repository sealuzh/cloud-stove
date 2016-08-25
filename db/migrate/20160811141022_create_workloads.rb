class CreateWorkloads < ActiveRecord::Migration
  def change
    create_table :cpu_workloads do |t|
      t.integer :cspu_user_capacity
      t.float :cspu_slope
      t.float :parallelism
      t.references :ingredient, index: true, foreign_key: true
      t.timestamps null: false
    end

    create_table :ram_workloads do |t|
      t.integer :ram_mb_required
      t.float :ram_mb_growth_per_user
      t.references :ingredient, index: true, foreign_key: true
      t.timestamps null: false
    end

    create_table :traffic_workloads do |t|
      t.integer :visits_per_month
      t.integer :requests_per_visit
      t.integer :request_size_kb
      t.references :ingredient, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
