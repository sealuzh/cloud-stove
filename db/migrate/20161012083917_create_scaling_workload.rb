class CreateScalingWorkload < ActiveRecord::Migration
  def change
    create_table :scaling_workloads do |t|
      t.boolean :scale_ingredient
      t.references :ingredient, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.timestamps
    end
  end
end
