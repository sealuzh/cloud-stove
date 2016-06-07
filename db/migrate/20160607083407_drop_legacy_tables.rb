class DropLegacyTables < ActiveRecord::Migration
  def change
    drop_table :slo_sets
    drop_table :concrete_components
    drop_table :deployment_rules
    drop_table :deployment_recommendations
    drop_table :components
    drop_table :application_deployment_recommendations
    drop_table :cloud_applications
    drop_table :blueprints
  end
end
