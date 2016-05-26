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

rails_app_instance.children.create(
  name: 'Rails App',
  body: <<HERE
Specific things about the Rails app.
HERE
)

rails_app_instance.children.create(
    name: 'PostgreSQL',
    body: <<HERE
Specific things about the PostgreSQL db.
HERE
)

rails_app_instance.children.create(
    name: 'NGINX',
    body: <<HERE
Specific things about the NGINX load balancer.
HERE
)

rails_app_instance.children.create(
    name: 'CDN',
    body: <<HERE
Specific things about the CDN.
HERE
)
