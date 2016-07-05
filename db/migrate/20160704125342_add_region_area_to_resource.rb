class AddRegionAreaToResource < ActiveRecord::Migration
  def change
    add_column :resources, :region_area, :string
  end
end
