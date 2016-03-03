require 'test_helper'

class AtlanticNetUpdaterTest < ActiveJob::TestCase
  setup do
    WebMock.stub_request(:post, 'https://cloudapi.atlantic.net/?Action=describe-plan').
        to_return(response_from('atlantic-net-pricing.txt'))
    ENV['ANC_ACCESS_KEY_ID'] = ENV['ANC_PRIVATE_KEY'] = 'test'
  end

  test 'creates resources in db' do
    assert_empty Provider.where(name: 'Atlantic.net')

    AtlanticNetUpdater.perform_now

    provider = Provider.find_by(name: 'Atlantic.net')
    assert_not_nil provider
    assert_not_empty provider.resources
    # As of 2016-03-03 there are 8 different instance types.
    # see https://www.atlantic.net/cloud-hosting/pricing/
    assert_equal 8, provider.resources.count
  end

end
