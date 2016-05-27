multitier_template = Ingredient.create(
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

app = multitier_template.children.create(
  name: 'Application Server',
  is_template: true,
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
app.constraints << RamConstraint.create(
  min_ram: 3064
)

db = multitier_template.children.create(
  name: 'Database',
  is_template: true,
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
db.constraints << RamConstraint.create(
    min_ram: 2048
)

lb = multitier_template.children.create(
  name: 'Load Balancer',
  is_template: true,
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
lb.constraints << RamConstraint.create(
    min_ram: 1024
)

cdn = multitier_template.children.create(
  name: 'Content Distribution Network',
  is_template: true,
  body: <<HERE
The **CDN** caches content close to users.

Use CDN service like [Cloudflare], [Incapsula], [Fastly], [Akamai],
[MaxCDN], [Amazon Cloudfront], [Google CDN].

[Cloudflare]: https://cloudflare.com
[Incapsula]: https://incapsula.com
[Fastly]: https://fastly.com
[Akamai]: https://akamai.com
[MaxCDN]: https://maxcdn.com
[Amazon Cloudfront]: https://aws.amazon.com/cloudfront
[Google CDN]: https://cloud.google.com/compute/docs/load-balancing/http/cdn

# Performance Considerations

You don't roll your own CDN unless you're Netflix.
HERE
)
cdn.constraints << RamConstraint.create(
    min_ram: 2048
)
