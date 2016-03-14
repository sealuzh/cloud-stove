require 'test_helper'

class GeneralStoriesTest < ActionDispatch::IntegrationTest
  test 'landing page has title text' do
    visit root_path
    assert page.has_content?('Finely crafted Cloud Application Deployments')
  end

  test "get application list" do
    get cloud_applications_path
    assert_response :success
  end

  test "get blueprints list" do
    get blueprints_path
    assert_response :success
  end

  test "get providers overview" do
    get providers_path
    assert_response :success
  end
end
