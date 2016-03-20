require 'test_helper'

class ProviderStoriesTest < ActionDispatch::IntegrationTest
  test 'listing providers' do
    aws = create(:aws_provider)

    visit providers_path
    assert page.has_content? 'Amazon'
    # TODO: The provider price list does not show up at all using PhantomJS or Selenium Javascript driver
    # assert page.has_content? 't2.nano'
  end
end
