rails_app_template = Ingredient.find_by_name!('Rails Application with PostgreSQL Backend')
rails_app_instance = Ingredient.create(
  template_id: rails_app_template.id,
  name: 'Rails Application with PostgreSQL Backend',
  body: <<HERE
A traditional wep application, let's say a web shop with

* Rails as the application server
  * Devise for authentication of authors and editors
  * Pundit for authorization
* PostgreSQL as database
  * Products are indexed on
    * name
    * categories
HERE
)
rails_app_instance.user_workload = UserWorkload.create(
  num_simultaneous_users: 200
)
rails_app_instance.provider_constraint = ProviderConstraint.create(
  preferred_providers: 'Amazon'
)
rails_app_instance.preferred_region_area_constraint = PreferredRegionAreaConstraint.create(
  preferred_region_area: 'EU'
)

db = rails_app_instance.children.create(
  name: 'PostgreSQL',
  body: <<HERE
Specific things about the PostgreSQL db.
HERE
)
db.ram_workload = RamWorkload.create(
  ram_mb_required: 1500,
  ram_mb_required_user_capacity: 200,
  ram_mb_growth_per_user: 0.007)
db.cpu_workload = CpuWorkload.create(
  cspu_user_capacity: 1500,
  parallelism: 0.9
)

app = rails_app_instance.children.create(
  name: 'Rails App',
  body: <<HERE
Specific things about the Rails app.
HERE
)
app.ram_workload = RamWorkload.create(
  ram_mb_required: 450,
  ram_mb_required_user_capacity: 100,
  ram_mb_growth_per_user: 1)
app.cpu_workload = CpuWorkload.create(
  cspu_user_capacity: 500,
  parallelism: 0.97
)
app.constraints << DependencyConstraint.create(
  source: app,
  target: db
)

lb = rails_app_instance.children.create(
    name: 'NGINX',
    body: <<HERE
Specific things about the NGINX load balancer.
HERE
)
lb.ram_workload = RamWorkload.create(
  ram_mb_required: 2000,
  ram_mb_required_user_capacity: 2400,
  ram_mb_growth_per_user: 0.008)
lb.cpu_workload = CpuWorkload.create(
  cspu_user_capacity: 3500,
  parallelism: 0.8
)
lb.constraints << DependencyConstraint.create(
  source: lb,
  target: app
)
rails_app_instance.assign_user!(User.admin.first)
