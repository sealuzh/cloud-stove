begin
multitier_template = Ingredient.create!(
  name: 'Multitier Architecture',
  is_template: true,
  body: <<HERE
Usually, an n-tier application consists of a set of application servers
backed by a database and fronted by load balancers, with a CDN serving
static content close to users. Find out more [on Wikipedia][1].

[1]: https://en.wikipedia.org/wiki/Multitier_architecture

# Basic Properties

2(3)-tier application:

- Web Frontend
- Application Server
- Database Backend'
HERE
)
multitier_template.provider_constraint = ProviderConstraint.create!(
  preferred_providers: 'Amazon'
)
multitier_template.preferred_region_area_constraint = PreferredRegionAreaConstraint.create!(
  preferred_region_area: 'EU'
)

db = multitier_template.children.create!(
  is_template: true,
  name: 'Database',
  icon: 'database',
  body: <<HERE
Database backend (usually [MySQL](http://mysql.org/) or PostgreSQL)
deployed on *single master instance* with hot standby (initial deployment)
or *clustered* with *write-only master* and *n read slaves* (larger
deployments).

# Performance Considerations

* Typically Disk I/O, RAM bound (CPU not as important).
* Either use provided DBaaS (e.g., Google Cloud SQL, Amazon RDS) or
  high I/O instance. For initial deployments, regular compute may be ok
  as well.
HERE
)
db.ram_workload = RamWorkload.create!(
  ram_mb_required: 1500,
  ram_mb_required_user_capacity: 200,
  ram_mb_growth_per_user: 0.007)
db.cpu_workload = CpuWorkload.create!(
  cspu_user_capacity: 1500,
  parallelism: 0.9
)
db.constraints << RamConstraint.create!(
  min_ram: 2048
)
db.constraints << CpuConstraint.create!(
  min_cpus: 1
)

app = multitier_template.children.create!(
  is_template: true,
  name: 'Application Server',
  icon: 'server',
  body: <<HERE
Rails/Spring Boot/JSF/Django/Yaws/Revel app deployed on **app server
group** using (puma|unicorn|passenger|...) to serve content (static and
dynamic). Sets caching headers to let upstream caches keep content for
some time.

# Performance Considerations

Typically, app servers are CPU and RAM bound (disk I/O not as
important), so basically any compute instance type is suitable.
*(Reference: George Reese, Cloud Application Architectures, chapter 7,
O’Reilly Media, 2009, ISBN 978-0-596-15636-7, e.g., on
[SafariBooks][1])*

[1]: http://proquest.tech.safaribooksonline.de/book/software-engineering-and-development/9780596157647/7dot-scaling-a-cloud-infrastructure/id3143621
HERE
)
app.ram_workload = RamWorkload.create!(
  ram_mb_required: 450,
  ram_mb_required_user_capacity: 100,
  ram_mb_growth_per_user: 0.8)
app.cpu_workload = CpuWorkload.create!(
  cspu_user_capacity: 500,
  parallelism: 0.97
)
app.constraints << DependencyConstraint.create!(
  source: app,
  target: db
)

lb = multitier_template.children.create!(
  is_template: true,
  name: 'Load Balancer',
  icon: 'sitemap',
  body: <<HERE
Load balancer distributes requests to app server group.

Either use provided LBaaS (e.g., [Amazon ELB], [Google Load Balancing])
or roll your own with Apache HTTPD/nginx/HAproxy/Pound.

[Amazon ELB]: https://aws.amazon.com/elasticloadbalancing/
[Google Load Balancing]: https://cloud.google.com/compute/docs/load-balancing/

# Performance Considerations

Typically Network I/O, CPU bound.
HERE
)
lb.ram_workload = RamWorkload.create!(
  ram_mb_required: 2000,
  ram_mb_required_user_capacity: 2400,
  ram_mb_growth_per_user: 0.008)
lb.cpu_workload = CpuWorkload.create!(
  cspu_user_capacity: 3500,
  parallelism: 0.8
)
lb.constraints << DependencyConstraint.create!(
  source: lb,
  target: app
)
multitier_template.assign_user!(User.admin.first)
end
