class AddUserIdToConstraints < ActiveRecord::Migration
  def change
    add_column :constraints, :user_id, :integer
  end
end
