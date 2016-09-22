require 'test_helper'

class DeviseTokenAuth::RegistrationsControllerTest < ActionController::TestCase
  test '[API] users#create (registrations#create)' do
    # Setup Devise routing for controller tests:
    # https://github.com/plataformatec/devise/wiki/How-To:-Test-controllers-with-Rails-3-and-4-(and-RSpec)#controller-tests-testunit
    @request.env['devise.mapping'] = Devise.mappings[:user]

    user = build_stubbed(:user)
    # Example:
    # post '/api/auth', { "email": <user.email>, "password": <user.password> }, format: json
    # Response > Body: { "status": "success", data": { "email": <user.email>, ... } }
    # Response > Header: { "Access-Token": "FhrnywrwRue3Nc5KMTdlKQ", ... }
    post :create, { email: user.email, password: user.password }
    assert_response :success

    assert_equal 'success', json_response['status']['success']
    assert_equal user.email, json_response['data']['email']
    # Capitalized in API (i.e., `Access-Token`) but lowercase here!
    refute_empty @response.header['access-token']
  end
end

class DeviseTokenAuth::SessionsControllerTest < ActionController::TestCase
  # Cannot test sign in isolation here as it would require mocking warden.
  # No need to test sessions as third party functionality from Devise anyways.

  # Example:
  # post '/api/auth/sign_in', { "email": <user.email>, "password": <user.password> }, format: json
  # Response > Body: { "data": { "email": <user.email>, ... } }
  # Response > Header: { "Access-Token": "FhrnywrwRue3Nc5KMTdlKQ", ... }
end
