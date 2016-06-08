class AddMinCpusToConstraints < ActiveRecord::Migration
  def change
    add_column :constraints, :min_cpus, :integer
  end
end
