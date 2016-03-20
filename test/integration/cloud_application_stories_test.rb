require 'test_helper'

class CloudApplicationStoriesTest < ActionDispatch::IntegrationTest
  test 'new cloud application from blueprint' do
    bp = create(:mt_blueprint)
    cloud_app = build_stubbed(:rails_cloud_application)
    webrick = build_stubbed(:concrete_component, :webrick)
    postgres = build_stubbed(:concrete_component, :postgres)

    visit blueprint_path(bp)
    click_link 'New Application Instance'

    fill_in 'cloud_application_name', with: cloud_app.name
    fill_in 'cloud_application_body', with: cloud_app.body
    fill_in 'cloud_application_concrete_components_attributes_0_name', with: webrick.name
    fill_in 'cloud_application_concrete_components_attributes_0_body', with: webrick.body
    fill_in 'cloud_application_concrete_components_attributes_1_name', with: postgres.name
    fill_in 'cloud_application_concrete_components_attributes_1_body', with: postgres.body
    click_button 'Save'

    assert page.has_content? 'Cloud application was successfully created.'
    assert page.has_content? webrick.name
    assert page.has_content? postgres.name
  end
end
