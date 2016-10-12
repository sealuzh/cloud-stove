class AddMaxNumInstancesToConstraints < ActiveRecord::Migration
  def change
    add_column :constraints, :max_num_instances, :integer
  end
end
