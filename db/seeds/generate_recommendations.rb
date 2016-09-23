begin
rails_app = Ingredient.where(name: 'Rails Application with PostgreSQL Backend', is_template: false).first
num_simultaneous_users_list = (500..5_000).step(500).to_a
num_simultaneous_users_list.each do |num_simultaneous_users|
  workload = rails_app.user_workload
  workload.num_simultaneous_users = num_simultaneous_users
  workload.save!
  rails_app.reload
  rails_app.schedule_recommendation_job(false)
end
end
