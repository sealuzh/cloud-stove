class AddCloudApplicationToConcreteComponents < ActiveRecord::Migration
  def change
    add_reference :concrete_components, :cloud_application, index: true, foreign_key: true
  end
end
