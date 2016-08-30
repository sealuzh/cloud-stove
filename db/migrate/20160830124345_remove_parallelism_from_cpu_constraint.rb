class RemoveParallelismFromCpuConstraint < ActiveRecord::Migration
  def change
    remove_column :cpu_workloads, :parallelism
  end
end
