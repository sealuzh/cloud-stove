class FixScalingWorkloadMigration < ActiveRecord::Migration
  def change
    leafs = Ingredient.select { |i| !i.application_root? }
    leafs.each do |leaf|
      if leaf.scaling_workload.nil?
        leaf.scaling_workload = ScalingWorkload.create!(
          scale_ingredient: false,
          user: leaf.user
        )
      end
    end
  end
end
