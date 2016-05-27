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

app = rails_app_instance.children.create(
  name: 'Rails App',
  body: <<HERE
Specific things about the Rails app.
HERE
)
app.constraints << RamConstraint.create(
    min_ram: 4096
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

lb = rails_app_instance.children.create(
    name: 'NGINX',
    body: <<HERE
Specific things about the NGINX load balancer.
HERE
)
lb.constraints << RamConstraint.create(
    min_ram: 1024
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
