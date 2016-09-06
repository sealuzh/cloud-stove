require 'test_helper'

class ApiAuthStoriesTest < ActionDispatch::IntegrationTest
  test '[API] create new user (sign up)' do
    user = build_stubbed(:user)
    post api_user_registration_path, { email: user.email, password: user.password }
    assert_equal 'success', json_response['status']
    assert_equal user.email, json_response['data']['email']
    refute_empty response.header['Access-Token']
  end

  test '[API] login existing user (sign in)' do
    user = create(:user)
    post api_user_session_path, { email: user.email, password: user.password }
    assert_response :success
    assert_equal user.email, json_response['data']['email']
  end

  test '[API] logout (sign out)' do
    auth_headers = create(:user).create_new_auth_token
    delete destroy_api_user_session_path, {}, auth_headers
    assert_response :success
  end
end
