require 'test_helper'

class ProvidersControllerTest < ActionController::TestCase
  test 'should get index' do
    auth_request(create(:user))
    get :index
    assert_response :success
  end
end
