namespace :docs do
  desc 'Update the `erd` figures for the `Developer_Guide.md`'
  task :update_figures  do
    sh 'bundle exec erd --notation=uml --polymorphism=true --inheritance \
        --attributes=false --exclude="User,Delayed::Backend::ActiveRecord::Job" \
        --filename=./docs/images/erd --filetype=svg \
        --orientation=vertical
      bundle exec erd --notation=uml --title="Ingredients" --only="Ingredient" \
        --inheritance --polymorphism --attributes=foreign_keys,content \
        --filename=./docs/images/erd-ingredient --filetype=svg
      bundle exec erd --notation=uml --title="Ingredients and Constraints" \
        --only="Ingredient,Constraint,DependencyConstraint,CpuConstraint,RamConstraint,PreferredRegionAreaConstraint,ProviderConstraint,ScalingConstraint" \
        --inheritance --polymorphism --attributes=foreign_keys,content \
        --filename=./docs/images/erd-ingredient-constraint --filetype=svg \
        --orientation=vertical
      bundle exec erd --notation=uml --title="Ingredients and Workloads" \
        --only="Ingredient,CpuWorkload,RamWorkload,TrafficWorkload,ScalingWorkload" \
        --inheritance --polymorphism --attributes=foreign_keys,content \
        --filename=./docs/images/erd-ingredient-workload --filetype=svg \
        --orientation=vertical
      bundle exec erd --notation=uml --title="Providers and Resources" \
        --only="Provider,Resource" \
        --inheritance --polymorphism --attributes=foreign_keys,content \
        --filename=./docs/images/erd-provider-resource --filetype=svg
      bundle exec erd --notation=uml --title="Deployment Recommendations" \
        --only="DeploymentRecommendation" \
        --inheritance --polymorphism --attributes=foreign_keys,content \
        --filename=./docs/images/erd-deploymentrecommendation --filetype=svg'
  end
end
