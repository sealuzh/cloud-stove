require 'test_helper'

class IngredientsControllerTest < ActionController::TestCase
  test 'delete an application' do
    i1 = create(:ingredient, user: @user)
    delete :destroy, id: i1.id
    assert_response :no_content
    assert_nil Ingredient.find_by_name(i1.name)
  end

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
    assert_equal a1.cpu_workload.cspu_user_capacity,
                 json_response[0]['workloads']['cpu_workload']['cspu_user_capacity']
  end

  test 'add a new ingredient' do
    i1 = attributes_for(:ingredient).merge(icon: 'database')
    post :create, ingredient: i1
    assert_response :success
    assert_equal i1[:name], json_response['name']
    assert_equal 'database', json_response['icon']
    assert_equal i1[:body], json_response['body']
  end

  test 'validate parent belongs to same user' do
    parent = create(:ingredient, user: create(:user))
    child_attr = attributes_for(:ingredient, parent_id: parent.id)
    post :create, ingredient: child_attr
    assert_response :error
    assert_equal 'Parent ingredient belongs to another user.', json_response['errors']['parent_user_mismatch'][0]
  end

  ## Admin only actions
  test 'listing template instances (admin only)' do
    use_admin
    t1 = create(:ingredient, :template, user: @user)
    i1 = t1.instantiate
    get :instances, ingredient_id: t1.id
    assert_response :success
    assert_equal 1, json_response.count
    assert_equal i1.name, json_response[0]['name']
  end

  test 'create a template from an application instance (admin only)' do
    use_admin
    a1 = create(:ingredient, user: @user)
    get :template, ingredient_id: a1.id
    assert_response :success
    assert_equal "[TEMPLATE] #{a1.name}", json_response['name']
  end

  test 'instantiate an application from a template' do
    admin = create(:user, :admin)
    t1 = create(:ingredient, :template, user: admin)
    get :instance, ingredient_id: t1.id
    assert_response :success
    assert_equal "[INSTANCE OF] #{t1.name}", json_response['name']
    assert_equal t1.id, json_response['template_id']
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

  test 'non-admin user cannot create a template' do
    get :template, ingredient_id: create(:ingredient).id
    assert_response :forbidden
    assert_equal 'Authorized admins only.', json_response['errors'][0]
  end

  test 'admin user can create a template' do
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

  # This behavior is used to display templates (which are public)
  test 'user can show admin ingredients' do
    admin = create(:user, :admin)
    admin_ingredient = create(:ingredient, user: admin)
    get :show, id: admin_ingredient.id
    assert_response :success
    assert_equal admin_ingredient.name, json_response['name']
  end
end
