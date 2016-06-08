SEEDS_ROOT = Rails.configuration.x.seeds_root

def require_seed(name)
  require (SEEDS_ROOT + name)
end

Dir.glob(SEEDS_ROOT + 'ingredient_template_*.rb').each { |f| require f }
Dir.glob(SEEDS_ROOT + 'ingredient_instance_*.rb').each { |f| require f }

require_seed 'update_provider'
