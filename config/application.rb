require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CloudStove
  class Application < Rails::Application
    config.assets.precompile << 'delayed/web/application.css'
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # add custom validators path
    config.autoload_paths += %W["#{config.root}/app/validators/"]

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.active_job.queue_adapter = :delayed_job

    # CORS Configuration for handling preflight RequestService
    config.middleware.insert_before 0, 'Rack::Cors' do
      allow do
        if ENV['DISABLE_CORS'] == 'true'
          origins '*'
        else
          origins 'localhost:1232',
                '127.0.0.1:1232',
                /\Ahttps:\/\/serene-garden-85460-pr-\d+\.herokuapp\.com.*\z/,
                'serene-garden-85460.herokuapp.com',
                'staging.frontend.thestove.io',
                'app.thestove.io'
        end
        resource '*',
                 :headers => :any,
                 :expose  => ['access-token', 'expiry', 'token-type', 'uid', 'client'],
                 :methods => [:get, :post, :delete, :put, :patch, :options, :head],
                 :max_age => 0
      end
    end

    ### Custom configuration using the recommended `config.x` property:
    # http://guides.rubyonrails.org/configuring.html#custom-configuration
    # Access using `Rails.configuration.x`
    config.x.gravatar_host = 'www.gravatar.com'
  end
end
