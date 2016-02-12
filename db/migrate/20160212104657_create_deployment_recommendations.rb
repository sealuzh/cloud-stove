class CreateDeploymentRecommendations < ActiveRecord::Migration
  def change
    create_table :deployment_recommendations do |t|
      t.text :more_attributes
      t.belongs_to :slo_set, index: true
      t.timestamps null: false
    end

    create_table :deployment_recommendations_resources, id: false do |t|
      t.belongs_to :deployment_recommendation, index:{:name => 'deployment_rec_index'}
      t.belongs_to :resource, index: {:name => 'resource_index'}
    end
  end
end
