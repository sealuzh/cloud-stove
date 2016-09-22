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
end
