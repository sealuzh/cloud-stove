class ChangeParallelismToFloat < ActiveRecord::Migration
  def change
    change_column :cpu_workloads, :parallelism,  :float
  end
end
