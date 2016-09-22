require 'test_helper'

class UserWorkloadsControllerTest < ActionController::TestCase
  test 'index' do
    get :index
    assert_response :success
  end

  test 'get' do
    user_workload = create(:user_workload, user: @user)
    get :show, {id: user_workload.id}
    assert_response :success
    assert_equal user_workload.num_simultaneous_users, json_response['num_simultaneous_users']
  end

  test 'user workloads gets updated' do
    ingredient = create(:ingredient, user: @user)
    user_workload = create(:user_workload, user: @user, ingredient: ingredient)
    new_workload = 7000
    put :update, { id: user_workload.id, user_workload: { num_simultaneous_users: new_workload, ingredient_id: ingredient.id } }
    assert_response :success
    assert_equal ({ 'id' => user_workload.id, 'num_simultaneous_users' => new_workload ,'ingredient_id' => ingredient.id }), json_response
    assert_equal ingredient.user_workload, user_workload
  end
end
