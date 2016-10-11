require 'test_helper'

class IngredientsControllerTest < ActionController::TestCase
  test 'listing templates' do
    t1 = create(:ingredient, :template)
    get :templates
    assert_response :success
    assert_equal 1, json_response.count
    assert_equal t1.name, json_response[0]['name']
  end

  test 'listing applications' do
    a1 = create(:ingredient, user: @user)
    get :index
    assert_response :success
    assert_equal 1, json_response.count
    assert_equal a1.name, json_response[0]['name']
  end

  test 'listing template instances (admin only)' do
    use_admin
    t1 = create(:ingredient, :template, user: @user)
    i1 = t1.instantiate
    get :instances, ingredient_id: t1.id
    assert_response :success
    assert_equal 1, json_response.count
    assert_equal i1.name, json_response[0]['name']
  end

  ### Authentication and authorization
  test 'open access to listing templates' do
    api_non_auth_header
    get :templates
    assert_response :success
  end

  test 'non-authenticated user cannot list applications' do
    api_non_auth_header
    get :index
    assert_response :unauthorized
    assert_equal 'Authorized users only.', json_response['errors'][0]
  end

  test 'non-admin user cannot create an ingredient' do
    get :template, ingredient_id: create(:ingredient).id
    assert_response :forbidden
    assert_equal 'Authorized admins only.', json_response['errors'][0]
  end

  test 'admin user can create an ingredient' do
    admin = create(:user, :admin)
    api_auth_header(admin)
    get :template, ingredient_id: create(:ingredient, user: admin).id
    assert_response :success
  end

  test 'users can only copy their own ingredients' do
    stranger = create(:user)
    ingredient = create(:ingredient, user: stranger)
    get :copy, ingredient_id: ingredient.id
    assert_response :not_found
  end
end
