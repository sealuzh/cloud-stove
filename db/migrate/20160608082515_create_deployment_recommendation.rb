class CreateDeploymentRecommendation < ActiveRecord::Migration
  def change
    create_table :deployment_recommendations do |t|
      t.text :more_attributes
      t.text :ingredients_data
      t.text :resources_data
      t.belongs_to :ingredient, index: true

      t.timestamps null: false
    end
  end
end
