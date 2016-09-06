require 'test_helper'

class ProviderStoriesTest < ActionDispatch::IntegrationTest
  test 'listing providers' do
    sign_in create(:user)
    amazon = create(:amazon_provider)
    google = create(:google_provider)

    visit providers_path
    assert page.has_content? amazon.name
    assert page.has_content? 't2.nano'
    assert page.has_content? 't2.micro'
    assert page.has_no_content?('storage'), 'Only show compute resources'

    assert page.has_content? google.name
    assert page.has_content? 'f1-micro'
  end
end
