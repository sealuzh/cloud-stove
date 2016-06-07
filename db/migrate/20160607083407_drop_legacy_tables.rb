class DropLegacyTables < ActiveRecord::Migration
  def change
    drop_table :blueprints
    drop_table :components
    drop_table :concrete_components
    drop_table :cloud_applications
    drop_table :deployment_recommendations
    drop_table :application_deployment_recommendations
    drop_table :deployment_rules
    drop_table :slo_sets
  end
end
