class AddProvidersToConstraint < ActiveRecord::Migration
  def change
    add_column :constraints, :preferred_providers, :string
  end
end
