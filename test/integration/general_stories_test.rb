require 'test_helper'

class GeneralStoriesTest < ActionDispatch::IntegrationTest
  test 'landing page has title text' do
    visit root_path
    assert page.has_content?('Finely crafted Cloud Application Deployments')
  end

  test 'create new application blueprint' do
    bp = Blueprint.new(name: 'bp1', body: 'body1')

    visit blueprints_path
    first(:link, 'New Blueprint').click
    fill_in('Name', with: bp.name)
    fill_in('Body', with: bp.body)
    click_link 'Add Component'
    click_button 'Save'

    assert page.has_content?('Blueprint was successfully created.')
    assert page.has_content?(bp.name)
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
