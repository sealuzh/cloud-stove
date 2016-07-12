class AddResourceCodeToResources < ActiveRecord::Migration
  def change
    add_column :resources, :resource_code, :integer, limit: 8
  end
end
