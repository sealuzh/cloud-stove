require 'simplecov'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'webmock/minitest'
require 'database_cleaner'

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
end

class ActiveSupport::TestCase
  # Consistently use FactoryGirl instead of fixtures
  include FactoryGirl::Syntax::Methods
  self.use_transactional_fixtures = false

  setup do
    if is_integration_test?
      setup_integration_test
    else
      setup_general_test
    end
    DatabaseCleaner.start
  end

  teardown do
    WebMock.disable!
    DatabaseCleaner.clean
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

  def setup_general_test
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

  def response_from(filename); self.class.response_from(filename); end
end
