require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'webmock/minitest'

require 'minitest/reporters'
Minitest::Reporters.use!(
    Minitest::Reporters::ProgressReporter.new,
    ENV,
    Minitest.backtrace_filter)

require 'capybara/rails'
require 'capybara/poltergeist'
class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  # Transactional fixtures do not work for Javascript-enabled
  # UI tests running in a separate thread
  self.use_transactional_fixtures = false
  # Do not load fixtures because this would be slow in combination
  # with the deletion/truncation DB cleaning strategy
  fixtures

  Capybara.javascript_driver = :poltergeist
  # Transaction cannot be used due to Poltergeist running in a separate thread
  # Deletion is often faster than truncation on Postgres
  DatabaseCleaner.strategy = :deletion

  setup do
    WebMock.disable!
    # Prohibit external connections but allow requests to localhost
    # Allows for local stubbing and ignoring external requests
    # by redirecting them to localhost. See:
    # https://robots.thoughtbot.com/using-capybara-to-test-javascript-that-makes-http
    WebMock.disable_net_connect!(allow_localhost: true)
    Capybara.current_driver = Capybara.javascript_driver
    DatabaseCleaner.start
  end

  teardown do
    DatabaseCleaner.clean
  end
end

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  setup do
    if ENV['ENABLE_NET_CONNECT']
      Rails.logger.warn 'WebMock is disabled. External services will be used.'
    else
      WebMock.enable!
      Rails.logger.info 'WebMock is active. No external services will be used.'
    end
  end

  teardown do
    WebMock.disable!
  end

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

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
