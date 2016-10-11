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

  ### Authentication
  test 'open access to listing templates' do
    api_non_auth_header
    get :templates
    assert_response :success
  end

  test 'non-authenticated user cannot list applications' do
    api_non_auth_header
    get :index
    assert_response :unauthorized
  end

  test 'non-admin user cannot create an ingredient' do
    get :template, ingredient_id: create(:ingredient).id
    assert_response :forbidden
  end

  test 'admin user can create an ingredient' do
    admin = create(:user, :admin)
    api_auth_header(admin)
    get :template, ingredient_id: create(:ingredient, user: admin).id
    assert_response :success
  end
end
