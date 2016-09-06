class AddUserIdtoTrafficWorkloads < ActiveRecord::Migration
  def change
    add_column :traffic_workloads, :user_id, :integer
  end
end
