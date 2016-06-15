source 'https://rubygems.org'

ruby File.read(File.dirname(__FILE__) + '/.ruby-version').chomp!

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.4'
# Use Haml for templates
gem 'haml-rails', '~> 0.9'
# Use Bootstrap, https://github.com/twbs/bootstrap-rubygem#a-ruby-on-rails
gem 'bootstrap', '~> 4.0.0.alpha3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use bourbon for Sass mixins
gem 'bourbon'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
#gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Markdown parser for pretty text
gem 'redcarpet'

# Delayed Web for Delayed Job views and management
gem 'delayed-web'

# FontAwesome for icons
gem 'font-awesome-sass', '~> 4.5.0'

# Tether for bootstrap tooltips and popovers
source 'https://rails-assets.org' do
  gem 'rails-assets-tether', '>= 1.1.0'
  gem 'rails-assets-jquery-timeago'
end

# Inline SVGs
gem 'inline_svg'

# Use kaminari for pagination
gem 'kaminari'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Puma as the app server
# gem 'puma'

# Use passenger as the app server
gem 'passenger'

# Use delayed_job for background jobs
gem 'delayed_job_active_record'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'
  gem 'pry'
  gem 'pry-rails' # Use pry as Rails console
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'quiet_assets'
  gem 'webmock'

  gem 'minitest-reporters'
  gem 'simplecov', require: false

  # Acceptance test framework for web applications: https://github.com/jnicklas/capybara
  gem 'capybara'
  # Support headless UI tests; Requires PhantomJS: http://phantomjs.org/
  gem 'poltergeist'
  # Different DB cleaning strategy is required for Javascript UI tests running in a separate thread
  gem 'database_cleaner'
  # Fixtures replacement for integration tests
  gem 'factory_girl_rails'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'guard'
  gem 'guard-minitest'
  gem 'guard-bundler'
  gem 'guard-pow', require: false
  gem 'terminal-notifier-guard'
  gem 'rack-livereload'
  gem 'guard-livereload', '~> 2.4', require: false
  gem 'rails-footnotes', '~> 4.0'
  gem 'benchmark-ips'
  # gem 'rack-mini-profiler'
  # gem 'flamegraph'
  # gem 'memory_profiler'
  gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]
end

# Configure CORS headers for frontend app
gem 'rack-cors', require: 'rack/cors'

gem 'rails_12factor', group: :production
# Use PostgreSQL as the database for production
gem 'pg', group: :production
