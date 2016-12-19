require 'test_helper'

class DeploymentRecommendationsControllerTest < ActionController::TestCase
  test 'listing recommendations for ingredient' do
    rails_app = create(:rails_app, user: @user)
    recommendation = create(:deployment_recommendation, ingredient: rails_app, user: @user)

    get :index, { ingredient_id: rails_app.id }
    assert_response :success
    assert_equal recommendation.id, json_response[0]['id']
    assert_equal recommendation.status, json_response[0]['status']
    assert_equal rails_app.children[0].name, json_response[0]['recommendation'][0]['ingredient']['name']
    assert_equal 't2.micro', json_response[0]['recommendation'][0]['resource']['name']
  end

  test 'trigger range' do
    rails_app = create(:rails_app, user: @user)
    rails_app.user_workload = create(:user_workload, user: @user)
    rails_app.children.each do |child|
      child.cpu_workload = create(:cpu_workload, user: @user)
      child.ram_workload = create(:ram_workload, user: @user)
    end

    post :trigger_range, ingredient_id: rails_app.id, min: 1000, max: 2000, step: 500
    assert_response :ok
    assert_equal 1, Delayed::Job.count
    assert_equal ' ConstructRecommendationsJob', JobWrapper.new(Delayed::Job.first).job_type
  end
end
