class AddMinRamToConstraints < ActiveRecord::Migration
  def change
    add_column :constraints, :min_ram, :integer
  end
end
