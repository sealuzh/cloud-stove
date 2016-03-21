require 'test_helper'

class GeneralStoriesTest < ActionDispatch::IntegrationTest
  test 'landing page has title text' do
    visit root_path
    assert page.has_content?('Finely crafted Cloud Application Deployments')
  end
end
