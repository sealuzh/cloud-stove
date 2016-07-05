require 'test_helper'

class JoyentUpdaterTest < ActiveJob::TestCase
  setup do
    WebMock.stub_request(:get, 'https://www.joyent.com/pricing').
        to_return(response_from('joyent-compute-pricing.txt'))

    WebMock.stub_request(:get, 'https://www.joyent.com/pricing/manta').
        to_return(response_from('joyent-storage-pricing.txt'))

  end

  test 'creates resources in db' do
    assert_empty Provider.where(name: 'Joyent')

    JoyentUpdater.new.perform

    provider = Provider.find_by(name: 'Joyent')
    assert_not_nil provider
    assert_not_empty provider.resources

    # As of 2016-07-05, there are 112 compute instance types
    # see https://www.joyent.com/public-cloud/pricing#hardwarevm
    assert_equal 112, provider.resources.where(resource_type: 'compute').count

    #As of 2016-07-05, there are 42 storage types
    # see https://www.joyent.com/object-storage/pricing
    assert_equal 42, provider.resources.where(resource_type: 'storage').count
  end
end
