class AddRamUserCapacityToRamWorkload < ActiveRecord::Migration
  def change
    add_column :ram_workloads, :ram_mb_required_user_capacity, :integer
  end
end
