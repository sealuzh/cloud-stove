require 'test_helper'

class ProvidersControllerTest < ActionController::TestCase
  test 'should get index' do
    use_admin
    get :index
    assert_response :success
  end
end
