require 'simplecov'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'webmock/minitest'
require 'database_cleaner'

# Test helpers
Dir[Rails.root.join("test/helpers/**/*.rb")].each { |f| require f }

require 'minitest/reporters'
Minitest::Reporters.use!(
    Minitest::Reporters::DefaultReporter.new(color: true),
    ENV,
    Minitest.backtrace_filter)

# Clean the database from any prior trash (e.g., caused by failing/interrupted tests)
DatabaseCleaner.clean_with :deletion

require 'capybara/rails'
require 'capybara/poltergeist'
class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  # Use the PhantomJS headless WebKit browser
  Capybara.javascript_driver = :poltergeist

  # Side-load assets from concurrently running app server
  # when using `save_and_open_page`
  Capybara.asset_host = 'http://localhost:3000'

  def reload_page page
    page.evaluate_script('window.location.reload()')
  end

  # Saving a page to public (for debugging) allows to serve it authentical (with assets) via `rails s`
  def show_page
    file = capybara_file
    dest = Rails.root.join('public', 'capybara', file)
    save_page dest
    url = "http://localhost:3000/capybara/#{file}"
    puts "File saved to: #{dest}
          Accessible via: #{url}"
    # Uncomment this if you want to immediately open the file
    # system("open #{url}")
  end

  private

  # Analogous to Capybara: https://github.com/jnicklas/capybara/blob/07e777742532ba4a0e4957f3241fc4fb6a903e86/lib/capybara/session.rb#L724
  def capybara_file
    timestamp = Time.new.strftime("%Y%m%d%H%M%S")
    "capybara-#{timestamp}#{rand(10**10)}.html"
  end
end

class ActionController::TestCase
  # Required to setup Devise and Warden environment for authentication
  include Devise::TestHelpers
  # Provide request shortcuts and JSON parsing helpers
  include Requests::JsonHelpers
  # API and authentication headers
  include Requests::HeadersHelpers

  setup do
    @user = create(:user)
    api_header
    api_auth_header(@user)
  end
end

class ActiveSupport::TestCase
  # Login helper for integration tests:
  # https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara
  include Warden::Test::Helpers

  # Consistently use FactoryGirl instead of fixtures
  include FactoryGirl::Syntax::Methods
  self.use_transactional_fixtures = false

  setup do
    if is_integration_test?
      setup_integration_test
    else
      setup_non_integration_test
    end
    DatabaseCleaner.start
  end

  teardown do
    WebMock.disable!
    DatabaseCleaner.clean
    Warden.test_reset!
  end

  def sign_in(user)
    login_as(user, :scope => :user)
  end

  def is_integration_test?
    self.is_a? ActionDispatch::IntegrationTest
  end

  def setup_integration_test
    WebMock.disable!
    # Prohibit external connections but allow requests to localhost
    # Allows for local stubbing and ignoring external requests
    # by redirecting them to localhost. See:
    # https://robots.thoughtbot.com/using-capybara-to-test-javascript-that-makes-http
    WebMock.disable_net_connect!(allow_localhost: true)
    Rails.logger.warn 'WebMock is disabled. External services are blocked. Local services are allowed.'

    Capybara.current_driver = Capybara.javascript_driver
    # Transaction cannot be used due to Poltergeist running in a separate thread
    # Deletion and truncation performed roughly the same
    DatabaseCleaner.strategy = :deletion
  end

  def setup_non_integration_test
    if ENV['ENABLE_NET_CONNECT']
      Rails.logger.warn 'WebMock is disabled. External services will be used.'
    else
      WebMock.enable!
      Rails.logger.info 'WebMock is active. No external services will be used.'
    end
    DatabaseCleaner.strategy = :transaction
  end

  # Read web request response stub from file in `test/stubs` directory
  #
  # To record a request for WebMock to replay later, save a response
  # using `curl -is`, e.g.
  #
  #     curl -is https://www.rackspace.com/cloud/public-pricing \
  #       >test/fixtures/stubs/rackspace-pricing.txt
  def self.response_from(filename)
    File.read(Rails.root + 'test/fixtures/webmock' + filename)
  end

  def response_from(filename)
    self.class.response_from(filename)
  end
end
