class DropUserWorkloads < ActiveRecord::Migration
  def change
    drop_table :user_workloads
  end
end
