class AddSloToConcreteComponent < ActiveRecord::Migration
  def change
    add_reference :slos , :concrete_components, index: true, foreign_key: true
  end
end
