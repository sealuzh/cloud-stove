require 'test_helper'

class BlueprintsControllerTest < ActionController::TestCase
  setup do
    @blueprint = create(:blueprint)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:blueprints)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should allow new from existing" do
    get :new, copy: @blueprint.id
    assert_response :success
    assert_routing copy_blueprints_path(@blueprint.id), { controller: 'blueprints', action: 'new', copy: @blueprint.id.to_s }
  end

  test "should create blueprint" do
    assert_difference('Blueprint.count') do
      post :create, blueprint: { more_attributes: @blueprint.more_attributes, name: @blueprint.name }
    end

    assert_redirected_to blueprint_path(assigns(:blueprint))
  end

  test "should show blueprint" do
    get :show, id: @blueprint
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @blueprint
    assert_response :success
  end

  test "should update blueprint" do
    patch :update, id: @blueprint, blueprint: { more_attributes: @blueprint.more_attributes, name: @blueprint.name }
    assert_redirected_to blueprint_path(assigns(:blueprint))
  end

  test "should destroy blueprint" do
    assert_difference('Blueprint.count', -1) do
      delete :destroy, id: @blueprint
    end

    assert_redirected_to blueprints_path
  end
end
