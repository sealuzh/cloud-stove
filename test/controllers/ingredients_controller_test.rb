require 'test_helper'

class IngredientsControllerTest < ActionController::TestCase
  test 'listing templates' do
    get :templates
    assert_response :success
  end

  test 'listing applications' do
    get :index
    assert_response :success
  end
end
