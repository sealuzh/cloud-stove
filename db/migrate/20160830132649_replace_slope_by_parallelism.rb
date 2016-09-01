class ReplaceSlopeByParallelism < ActiveRecord::Migration
  def change
    rename_column :cpu_workloads, :cspu_slope, :parallelism
  end
end
