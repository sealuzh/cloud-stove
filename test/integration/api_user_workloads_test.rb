require 'test_helper'

class ApiUserWorkloadsTest < ActionDispatch::IntegrationTest
  test 'user workloads gets updated' do
    user = create(:user)
    ingredient = create(:ingredient, user: user)
    user_workload = create(:user_workload, user: user, ingredient: ingredient)
    new_workload = 7000
    headers = user.create_new_auth_token.merge!({'Accept' => 'application/json', 'Content-Type' => 'application/json'})
    put user_workload_path(user_workload), { user_workload: { num_simultaneous_users: new_workload, ingredient_id: ingredient.id } }.to_json, headers
    assert_response :success
    assert_equal ({ 'id' => user_workload.id, 'num_simultaneous_users' => new_workload ,'ingredient_id' => ingredient.id }), json_response
    assert_equal ingredient.user_workload, user_workload
  end

  test 'posting multiple times to user workloads' do
    user = create(:user)
    ingredient = create(:ingredient, user: user)
    user_workload = create(:user_workload, user: user, ingredient: ingredient)
    new_workload = 7000
    headers = user.create_new_auth_token.merge!({'Accept' => 'application/json', 'Content-Type' => 'application/json'})
    post user_workloads_path, { user_workload: { num_simultaneous_users: new_workload, ingredient_id: ingredient.id } }.to_json, headers
    post user_workloads_path, { user_workload: { num_simultaneous_users: new_workload, ingredient_id: ingredient.id } }.to_json, headers
    assert_response :success
    # TODO: Use a suitable JSON matching instead of optimistically hardcoding the id
    assert_equal ({ 'id' => user_workload.id + 2, 'num_simultaneous_users' => new_workload ,'ingredient_id' => ingredient.id }), json_response
  end
end
