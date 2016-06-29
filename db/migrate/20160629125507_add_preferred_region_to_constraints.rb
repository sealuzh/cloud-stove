class AddPreferredRegionToConstraints < ActiveRecord::Migration
  def change
    add_column :constraints, :preferred_region, :string
  end
end
