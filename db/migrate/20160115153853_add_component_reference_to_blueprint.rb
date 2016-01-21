class AddComponentReferenceToBlueprint < ActiveRecord::Migration
  def change
    remove_reference :components, :cloud_application, index: true, foreign_key: true
    add_reference :components , :blueprint, index: true, foreign_key: true
  end
end
