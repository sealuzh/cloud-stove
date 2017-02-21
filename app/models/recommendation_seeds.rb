# Provides utilities to update the recommendations of the admin user.
# These recommendations are used to seed newly created users.
class RecommendationSeeds
  # NOTICE: The Rails app of the admin user is used to seed newly created users
  def self.update_admin_recommendations
    admin_user = User.stove_admin
    rails_app = Ingredient.where(name: 'Rails Application with PostgreSQL Backend',
                                 user: admin_user, is_template: false).first
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
    app.construct_recommendations(num_simultaneous_users_list, perform_later: false)
  end
end
