class AddUserIdToWorkloads < ActiveRecord::Migration
  def change
    add_column :cpu_workloads, :user_id, :integer
    add_column :ram_workloads, :user_id, :integer
    add_column :user_workloads, :user_id, :integer
  end
end
