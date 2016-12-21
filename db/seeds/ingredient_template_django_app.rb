begin
django_app_template = Ingredient.create!(
  is_template: true,
  name: 'Django Application with PostgreSQL Backend',
  body: <<-HERE
A traditional wep application, let's say a web shop with

* Django on Gunicorn as the application server
* Celery for background processing
* RabbitMQ to manage the background processing queue
* PostgreSQL as database
HERE
)
django_app_template.provider_constraint = ProviderConstraint.create!(
  preferred_providers: 'Amazon,Google'
)
django_app_template.preferred_region_area_constraint = PreferredRegionAreaConstraint.create!(
  preferred_region_area: 'EU'
)

db = django_app_template.children.create!(
  is_template: true,
  name: 'PostgreSQL Master',
  body: <<-HERE
The typical RDBMS backend of a Django application stores all data. 
To speed up db access, sensible indices are defined on commonly 
queried attributes.
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

db_slave = django_app_template.children.create!(
  is_template: true,
  name: 'PostgreSQL Slave',
  body: <<-HERE
The typical RDBMS backend of a Django application stores all data. 
To speed up db access, sensible indices are defined on commonly 
queried attributes.
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
  scale_ingredient: false
)

queue = django_app_template.children.create!(
  is_template: true,
  name: 'RabbitMQ',
  body: <<-HERE
The message queue is used to schedule background jobs with Celery.
HERE
)
queue.ram_workload = RamWorkload.create!(
  ram_mb_required: 512,
  ram_mb_required_user_capacity: 900,
  ram_mb_growth_per_user: 0.1)
queue.cpu_workload = CpuWorkload.create!(
  cspu_user_capacity: 900,
  parallelism: 0.9
)
queue.scaling_workload = ScalingWorkload.create!(
  scale_ingredient: true
)

app = django_app_template.children.create!(
  is_template: true,
  name: 'Django Application Server',
  body: <<-HERE
The Gunicorn application server running the Django application.

HERE
)
app.ram_workload = RamWorkload.create!(
  ram_mb_required: 350,
  ram_mb_required_user_capacity: 200,
  ram_mb_growth_per_user: 0.025)
app.cpu_workload = CpuWorkload.create!(
  cspu_user_capacity: 600,
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
  target: queue
)

worker = django_app_template.children.create!(
    is_template: true,
    name: 'Celery Workers',
    body: <<-HERE
The Celery workers get new tasks via RabbitMQ and execute them asynchronously.
HERE
)
worker.ram_workload = RamWorkload.create!(
  ram_mb_required: 600,
  ram_mb_required_user_capacity: 3000,
  ram_mb_growth_per_user: 0.007)
worker.cpu_workload = CpuWorkload.create!(
  cspu_user_capacity: 1700,
  parallelism: 0.9
)
worker.scaling_workload = ScalingWorkload.create!(
  scale_ingredient: true
)

worker.constraints << DependencyConstraint.create!(
  source: queue,
  target: worker
)
worker.constraints << DependencyConstraint.create!(
  source: worker,
  target: db
)
django_app_template.assign_user!(User.admin.first)
end
