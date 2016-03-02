require 'test_helper'

class CloudApplicationsControllerTest < ActionController::TestCase
  setup do
    @cloud_application = cloud_applications(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cloud_applications)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get new for copy" do
    get :new, copy: @cloud_application
    assert_response :success
    assert_not_nil assigns(:cloud_application)
    assert_routing copy_cloud_applications_path(@cloud_application), { controller: 'cloud_applications', action: 'new', copy: @cloud_application.to_param }
  end

  test "should get new for instance from blueprint" do
    blueprint = blueprints(:multitier_app)
    get :new, blueprint: blueprint.id
    assert_response :success
    assert_not_nil @controller.params[:blueprint]
  end

  test "should create cloud_application" do
    assert_difference('CloudApplication.count') do
      post :create, cloud_application: { name: "Test"  }
    end

    assert_redirected_to cloud_application_path(assigns(:cloud_application))
  end

  test "should show cloud_application" do
    get :show, id: @cloud_application
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @cloud_application
    assert_response :success
  end

  test "should update cloud_application" do
    patch :update, id: @cloud_application, cloud_application: { name: "Test" }
    assert_redirected_to cloud_application_path(assigns(:cloud_application))
  end

  test "should destroy cloud_application" do
    assert_difference('CloudApplication.count', -1) do
      delete :destroy, id: @cloud_application
    end

    assert_redirected_to cloud_applications_path
  end
end
