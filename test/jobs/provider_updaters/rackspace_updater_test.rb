require 'test_helper'

class RackspaceUpdaterTest < ActiveJob::TestCase
  setup do
    WebMock.stub_request(:get, 'https://www.rackspace.com/cloud/public-pricing').
        to_return(response_from('rackspace-pricing.txt'))
  end

  test 'creates resources in db' do
    assert_empty Provider.where(name: 'Rackspace')

    RackspaceUpdater.perform_now

    provider = Provider.find_by(name: 'Rackspace')
    assert_not_nil provider
    assert_not_empty provider.resources
  end

end
