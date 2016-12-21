begin
node_app_template = Ingredient.create!(
  is_template: true,
  name: 'NodeJS Application with MongoDB Backend',
  icon: 'server',
  body: <<-HERE
A wep application, let's say a web shop with

* NodeJS as the application server
* MongoDB as database
HERE
)
node_app_template.provider_constraint = ProviderConstraint.create!(
  preferred_providers: 'Amazon,Google'
)
node_app_template.preferred_region_area_constraint = PreferredRegionAreaConstraint.create!(
  preferred_region_area: 'EU'
)

db = node_app_template.children.create!(
  is_template: true,
  name: 'MongoDB',
  icon: 'database',
  body: <<-HERE
The MongoDB backend stores all data.
HERE
)
db.ram_workload = RamWorkload.create!(
  ram_mb_required: 2048,
  ram_mb_required_user_capacity: 200,
  ram_mb_growth_per_user: 1)
db.cpu_workload = CpuWorkload.create!(
  cspu_user_capacity: 2500,
  parallelism: 0.9
)
db.scaling_workload = ScalingWorkload.create!(
  scale_ingredient: true
)

app = node_app_template.children.create!(
  is_template: true,
  name: 'NodeJS Application Server',
  icon: 'server',
  body: <<-HERE
The NodeJS application server hosting the application.

HERE
)
app.ram_workload = RamWorkload.create!(
  ram_mb_required: 350,
  ram_mb_required_user_capacity: 250,
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
node_app_template.assign_user!(User.admin.first)
end
