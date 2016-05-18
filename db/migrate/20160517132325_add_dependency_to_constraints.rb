class AddDependencyToConstraints < ActiveRecord::Migration
  def change
      add_column :constraints, :type, :string
      add_reference :constraints, :source, references: :ingredient, index: true
      add_reference :constraints, :target, references: :ingredient, index: true
  end
end
