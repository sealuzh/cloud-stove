require 'test_helper'

class GeneralStoriesTest < ActionDispatch::IntegrationTest
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
