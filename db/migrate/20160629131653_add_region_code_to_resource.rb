class AddRegionCodeToResource < ActiveRecord::Migration
  def change
    add_column :resources, :region_code, :integer
  end
end
