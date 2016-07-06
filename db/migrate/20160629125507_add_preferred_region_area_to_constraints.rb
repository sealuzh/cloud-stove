class AddPreferredRegionAreaToConstraints < ActiveRecord::Migration
  def change
    add_column :constraints, :preferred_region_area, :string
  end
end
