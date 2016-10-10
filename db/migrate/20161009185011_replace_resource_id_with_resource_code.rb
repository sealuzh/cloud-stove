class ReplaceResourceIdWithResourceCode < ActiveRecord::Migration
  def change
    add_index :resources, :resource_code

    resource_ids_to_resource_code_transactional
  end

  private

    def resource_ids_to_resource_code_transactional
      ActiveRecord::Base.transaction do
        resource_ids_to_resource_code
      end
    end

    # CAVEAT: This migration might fail if the `DeploymentRecommendation` or `Resource` model undergoes breaking changes!
    def resource_ids_to_resource_code
      DeploymentRecommendation.find_each do |recommendation|
        if recommendation.ma['ingredients']
          recommendation.ma['ingredients'].update(recommendation.ma['ingredients']) do |_, resource_id|
            Resource.find(resource_id).resource_code
          end
          recommendation.save!
        end
      end
    end
end
