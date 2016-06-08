multitier_template = Ingredient.find_by_name!('Multitier Architecture')
rails_app_instance = Ingredient.create(
  template_id: multitier_template,
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

db = rails_app_instance.children.create(
  name: 'PostgreSQL',
  body: <<HERE
Specific things about the PostgreSQL db.
HERE
)
db.constraints << RamConstraint.create(
  min_ram: 2048
)
db.constraints << CpuConstraint.create(
  min_cpus: 1
)

app = rails_app_instance.children.create(
  name: 'Rails App',
  body: <<HERE
Specific things about the Rails app.
HERE
)
app.constraints << RamConstraint.create(
  min_ram: 4096
)
app.constraints << CpuConstraint.create(
  min_cpus: 1
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
lb.constraints << RamConstraint.create(
  min_ram: 1024
)
lb.constraints << CpuConstraint.create(
  min_cpus: 1
)
lb.constraints << DependencyConstraint.create(
  source: lb,
  target: app
)

cdn = rails_app_instance.children.create(
    name: 'CDN',
    body: <<HERE
Specific things about the CDN.
HERE
)
cdn.constraints << RamConstraint.create(
  min_ram: 2048
)
cdn.constraints << CpuConstraint.create(
  min_cpus: 1
)
cdn.constraints << DependencyConstraint.create(
  source: cdn,
  target: lb
)
