class AddTypeToResources < ActiveRecord::Migration
  def change
    add_column :resources, :resource_type, :string
  end
end
