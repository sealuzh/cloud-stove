class CreateSlos < ActiveRecord::Migration
  def change
    create_table :slos do |t|
      t.text :more_attributes

      t.timestamps null: false
    end
  end
end
