class CreateDeploymentRules < ActiveRecord::Migration
  def change
    create_table :deployment_rules do |t|
      t.text :more_attributes
      t.references :component, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
