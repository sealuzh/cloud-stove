class RecommendationSeeds
  # NOTICE: The Rails app of the admin user is used to seed newly created users
  def self.update_admin_recommendations
    admin_user = User.admin.first
    rails_app = Ingredient.where(name: 'Rails Application with PostgreSQL Backend', user: admin_user, is_template: false).first
    self.update_recommendations(rails_app)
  end

  def self.update_recommendations(app)
    ActiveRecord::Base.transaction do
      delete_recommendations(app)
      generate_recommendations(app)
    end
  end

  def self.delete_recommendations(app)
    app.deployment_recommendations.destroy_all
  end

  def self.generate_recommendations(app)
    num_simultaneous_users_list = (500..5_000).step(500).to_a
    num_simultaneous_users_list.each do |num_simultaneous_users|
      workload = app.user_workload
      workload.num_simultaneous_users = num_simultaneous_users
      workload.save!
      app.reload
      app.schedule_recommendation_job(false)
    end
  end
end
