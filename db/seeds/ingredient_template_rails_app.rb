begin
rails_app_template = Ingredient.create!(
  is_template: true,
  name: 'Rails Application with PostgreSQL Backend',
  body: <<-HERE
A traditional wep application, let's say a web shop with

* Ruby on Rails on Puma as the application server
  * Devise for authentication of authors and editors
  * Pundit for authorization
* Delayed Job for background processing
* PostgreSQL as database
  * Products are indexed on
    * name
    * categories
HERE
)
rails_app_template.provider_constraint = ProviderConstraint.create!(
  preferred_providers: 'Amazon,Google'
)
rails_app_template.preferred_region_area_constraint = PreferredRegionAreaConstraint.create!(
  preferred_region_area: 'EU'
)

db = rails_app_template.children.create!(
  is_template: true,
  name: 'PostgreSQL Master',
  icon: 'database',
  body: <<-HERE
The typical RDBMS backend of a Rails application stores all data and is used 
by Delayed Job to schedule background tasks. To speed up db access, sensible
indices are defined on commonly queried attributes.
HERE
)
db.ram_workload = RamWorkload.create!(
  ram_mb_required: 600,
  ram_mb_required_user_capacity: 200,
  ram_mb_growth_per_user: 0.3)
db.cpu_workload = CpuWorkload.create!(
  cspu_user_capacity: 1500,
  parallelism: 0.9
)
db.scaling_workload = ScalingWorkload.create!(
  scale_ingredient: false
)

db_slave = rails_app_template.children.create!(
  is_template: true,
  name: 'PostgreSQL Slave',
  icon: 'database',
  body: <<-HERE
The typical RDBMS backend of a Rails application stores all data and is used 
by Delayed Job to schedule background tasks. To speed up db access, sensible
indices are defined on commonly queried attributes.
HERE
)
db_slave.ram_workload = RamWorkload.create!(
  ram_mb_required: 600,
  ram_mb_required_user_capacity: 200,
  ram_mb_growth_per_user: 0.3)
db_slave.cpu_workload = CpuWorkload.create!(
  cspu_user_capacity: 1500,
  parallelism: 0.9
)
db_slave.scaling_workload = ScalingWorkload.create!(
  scale_ingredient: true
)

app = rails_app_template.children.create!(
  is_template: true,
  name: 'Rails Application Server',
  icon: 'server',
  body: <<-HERE
The Puma application server running the Rails application.

HERE
)
app.ram_workload = RamWorkload.create!(
  ram_mb_required: 450,
  ram_mb_required_user_capacity: 150,
  ram_mb_growth_per_user: 0.03)
app.cpu_workload = CpuWorkload.create!(
  cspu_user_capacity: 500,
  parallelism: 0.97
)
app.scaling_workload = ScalingWorkload.create!(
  scale_ingredient: true
)
app.constraints << DependencyConstraint.create!(
  source: app,
  target: db
)
app.constraints << DependencyConstraint.create!(
  source: app,
  target: db_slave
)

worker = rails_app_template.children.create!(
  is_template: true,
  name: 'Delayed Job Workers',
  icon: 'cog',
  body: <<-HERE
The Delayed Job workers periodically query the database for new tasks and
execute them asynchronously.
HERE
)
worker.ram_workload = RamWorkload.create!(
  ram_mb_required: 500,
  ram_mb_required_user_capacity: 2400,
  ram_mb_growth_per_user: 0.008)
worker.cpu_workload = CpuWorkload.create!(
  cspu_user_capacity: 1500,
  parallelism: 0.9
)
worker.scaling_workload = ScalingWorkload.create!(
  scale_ingredient: true
)
worker.constraints << DependencyConstraint.create!(
  source: worker,
  target: db
)
rails_app_template.assign_user!(User.admin.first)
end
