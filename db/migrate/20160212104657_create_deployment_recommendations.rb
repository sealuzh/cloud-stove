class CreateDeploymentRecommendations < ActiveRecord::Migration
  def change
    create_table :deployment_recommendations do |t|
      t.text :more_attributes
      t.belongs_to :slo_set, index: true
      t.timestamps null: false
    end
  end
end
