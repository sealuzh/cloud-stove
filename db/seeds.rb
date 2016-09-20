SEEDS_ROOT = Rails.root + 'db/seeds/'

def require_seed(name)
  require (SEEDS_ROOT + name)
end

module ActiveRecord
  class Relation
    # Create idempotent seed records.
    #
    # Will search for a seed record using `attributes` and then yield the
    # found/created record to the given block.
    #
    # The seed record will be saved automatically.
    #
    def seed_with!(attributes)
      find_or_initialize_by(attributes).tap do |s|
        yield s if block_given?
        s.save!
      end
    end
  end

  module Querying
    delegate :seed_with!, to: :all
  end
end

# User MUST be loaded first
require_seed 'admin_user'

# Template MUST be loaded before instances
require_seed 'ingredient_template_multitier'
require_seed 'ingredient_instance_rails_app'
require_seed 'ingredient_template_rails_app'
require_seed 'ingredient_template_django_app'
require_seed 'ingredient_template_node_app'

# Selectively load seeds for demo instead of loading them all
# Dir.glob(SEEDS_ROOT + 'ingredient_template_*.rb').each { |f| require f }
# Dir.glob(SEEDS_ROOT + 'ingredient_instance_*.rb').each { |f| require f }

require_seed 'update_provider'
