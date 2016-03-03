require 'test_helper'

class JoyentUpdaterTest < ActiveJob::TestCase
  setup do
    WebMock.stub_request(:get, 'https://www.joyent.com/assets/js/pricing.json').
        to_return(response_from('joyent-compute-pricing.txt'))
  end

  test 'creates resources in db' do
    assert_empty Provider.where(name: 'Joyent')

    JoyentUpdater.perform_now

    provider = Provider.find_by(name: 'Joyent')
    assert_not_nil provider
    assert_not_empty provider.resources
    # As of 2016-03-03, there are 18 compute instance types
    # see https://www.joyent.com/public-cloud/pricing#hardwarevm
    assert_equal 18, provider.resources.count
  end
end
