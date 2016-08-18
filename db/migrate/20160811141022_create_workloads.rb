class CreateWorkloads < ActiveRecord::Migration
  def change
    create_table :workloads do |t|
      t.integer :cpu_level
      t.integer :ram_level
      t.integer :visits_per_month
      t.integer :requests_per_visit
      t.integer :request_size_kb
      t.references :ingredient, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
