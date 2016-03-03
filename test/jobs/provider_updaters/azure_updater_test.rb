require 'test_helper'

class AzureUpdaterTest < ActiveJob::TestCase
  setup do
    WebMock.stub_request(:get, 'https://azure.microsoft.com/en-us/pricing/details/virtual-machines/').
        to_return(response_from('azure-pricing.txt'))
    WebMock.stub_request(:get, 'https://azure.microsoft.com/en-us/support/legal/sla/virtual-machines/v1_0/').
        to_return(response_from('azure-sla.txt'))
  end

  test 'creates resources in db' do
    assert_empty Provider.where(name: 'Microsoft Azure')

    AzureUpdater.perform_now

    provider = Provider.find_by(name: 'Microsoft Azure')
    assert_not_nil provider
    assert_not_empty provider.resources
  end

end
