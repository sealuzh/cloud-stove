require 'test_helper'

class ResourcesControllerTest < ActionController::TestCase
  test 'should index all resources' do
    create(:amazon_provider)
    create(:google_provider)
    get :index
    assert_response :success
    assert_equal 5, json_response.count
  end

  test 'should filter by provider' do
    create(:amazon_provider)
    create(:google_provider)
    get :index, provider_name: 'Amazon'
    assert_equal ['Amazon'], json_response.map { |r| r['provider'] }.uniq
  end

  test 'should filter by region area' do
    create(:azure_provider)
    create(:google_provider)
    get :index, region_area: 'US'
    assert_equal ['US'], json_response.map { |r| r['region_area'] }.uniq
  end
end
