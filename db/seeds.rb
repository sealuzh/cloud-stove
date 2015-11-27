# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
rails_app = CloudApplication.find_or_create_by(name: 'A Rails app with PostgreSQL')
rails_app.components.find_or_create_by(component_type: 'frontend') do |c|
  c.name = 'Rails'
  c.more_attributes = { lang: :ruby, dependencies: Bundler.locked_gems.dependencies }
end
rails_app.components.find_or_create_by(component_type: 'database') do |c|
  c.name = 'PostgreSQL'
  c.more_attributes = { records_per_user: 123, something_interesting: :absolutely }
end

spring_app = CloudApplication.find_or_create_by(name: 'A Spring Boot app with CouchDB')

nodejs_app = CloudApplication.find_or_create_by(name: 'A NodeJS app with Cassandra')
