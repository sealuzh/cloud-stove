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

  test 'find deployment recommendations' do
    amazon = create(:amazon_provider)
    google = create(:google_provider)
    cloud_app = create(:rails_cloud_application)

    visit cloud_application_path cloud_app
    assert_equal 0, Delayed::Job.count
    click_link 'Find optimal deployments'
    page.accept_alert

    assert_equal 1, Delayed::Job.count
    assert_equal 0, ApplicationDeploymentRecommendation.count
    Delayed::Job.first.invoke_job # NOTE: does not remove it. Would require `job.destroy`
    assert_equal 2, ApplicationDeploymentRecommendation.count
    reload_page page

    assert page.has_content? 'Deployment Costs:'
    assert page.has_content? amazon.name
    assert page.has_content? google.name
    # TODO: Activate when deployment recommendations are fixed
    # assert page.has_no_content? '$0.00', 'Deployment costs must be > 0'

    click_link amazon.name
    assert page.has_content? cloud_app.concrete_components.first.name
    assert page.has_content? cloud_app.concrete_components.last.name
  end
end
