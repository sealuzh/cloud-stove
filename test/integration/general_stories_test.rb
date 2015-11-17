require 'test_helper'

class GeneralStoriesTest < ActionDispatch::IntegrationTest
  test "get application list" do
    get cloud_applications_path
    assert_response :success
  end
end
