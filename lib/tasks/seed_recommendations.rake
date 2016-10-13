namespace :seeds do
  desc 'Re-creates recommendation seeds for the admin user'
  task update_recommendations: :environment do
    RecommendationSeeds.update_admin_recommendations
  end
end
