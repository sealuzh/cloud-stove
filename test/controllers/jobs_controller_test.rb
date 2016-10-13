require 'test_helper'
class JobsControllerTest < ActionController::TestCase
  test 'non-admin cannot list jobs' do
    get :index
    assert_response :forbidden
  end
end
