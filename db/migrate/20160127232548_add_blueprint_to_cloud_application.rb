class AddBlueprintToCloudApplication < ActiveRecord::Migration
  def change
    add_reference :cloud_applications, :blueprint, index: true, foreign_key: true
  end
end
