namespace :seeds do
  desc 'Updates the template and application seeds and migrates existing references'
  task update_templates: :environment do
    update_templates
  end

  def require_seed(name)
    seeds_root = Rails.root + 'db/seeds/'
    require (seeds_root + name)
  end

  def update_templates
    update_rails
    update_django
    update_node
    RecommendationSeeds.update_admin_recommendations
  end

  def update_rails
    ActiveRecord::Base.transaction do
      admin_user = User.stove_admin
      old_rails_app = Ingredient.where(name: 'Rails Application with PostgreSQL Backend', user: admin_user, is_template: false).first.destroy!
      old_rails_template = Ingredient.where(name: 'Rails Application with PostgreSQL Backend', user: admin_user, is_template: true).first.destroy!
      require_seed 'ingredient_template_rails_app'
      rails_template = Ingredient.where(name: 'Rails Application with PostgreSQL Backend', user: admin_user, is_template: true).first
      Ingredient.where(template_id: old_rails_template.id).each { |i| i.template_id = rails_template.id; i.save! }
      require_seed 'ingredient_instance_rails_app'
    end
  rescue => e
    puts "[WARNING] Couldn't update rails template and application seeds. #{e.message}"
  end

  def update_django
    ActiveRecord::Base.transaction do
      admin_user = User.stove_admin
      old_django_template = Ingredient.where(name: 'Django Application with PostgreSQL Backend', user: admin_user, is_template: true).first.destroy!
      require_seed 'ingredient_template_django_app'
      django_template = Ingredient.where(name: 'Django Application with PostgreSQL Backend', user: admin_user, is_template: true).first
      Ingredient.where(template_id: old_django_template.id).each { |i| i.template_id = django_template.id; i.save! }
    end
  rescue => e
    puts "[WARNING] Couldn't update django template seeds. #{e.message}"
  end

  def update_node
    ActiveRecord::Base.transaction do
      admin_user = User.stove_admin
      old_node_template = Ingredient.where(name: 'NodeJS Application with MongoDB Backend', user: admin_user, is_template: true).first.destroy!
      require_seed 'ingredient_template_node_app'
      node_template = Ingredient.where(name: 'NodeJS Application with MongoDB Backend', user: admin_user, is_template: true).first
      Ingredient.where(template_id: old_node_template.id).each { |i| i.template_id = node_template.id; i.save! }
    end
  rescue => e
    puts "[WARNING] Couldn't update node template seeds. #{e.message}"
  end
end
