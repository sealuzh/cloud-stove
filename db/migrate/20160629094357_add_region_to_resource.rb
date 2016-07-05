class AddRegionToResource < ActiveRecord::Migration
  def change
    add_column :resources, :region, :string
  end
end
