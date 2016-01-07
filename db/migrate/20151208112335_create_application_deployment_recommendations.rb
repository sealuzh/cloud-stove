class CreateApplicationDeploymentRecommendations < ActiveRecord::Migration
  def change
    create_table :application_deployment_recommendations do |t|
      t.text :more_attributes
      t.references :cloud_application, index: { name: 'index_app_dep_rec_on_cloud_app_id' }, foreign_key: true

      t.timestamps null: false
    end
  end
end
