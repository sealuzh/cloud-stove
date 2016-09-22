require 'test_helper'

class AzureUpdaterTest < ActiveJob::TestCase
  setup do
    WebMock.stub_request(:get, 'https://azure.microsoft.com/en-us/pricing/details/virtual-machines/').
        to_return(response_from('azure-pricing.txt'))
    WebMock.stub_request(:get, 'https://azure.microsoft.com/en-us/support/legal/sla/virtual-machines/v1_0/').
        to_return(response_from('azure-compute-sla.txt'))

    WebMock.stub_request(:get, 'https://azure.microsoft.com/en-us/pricing/details/storage/').
        to_return(response_from('azure-storage.txt'))
    WebMock.stub_request(:get, 'https://azure.microsoft.com/en-us/support/legal/sla/storage/v1_0/').
        to_return(response_from('azure-storage-sla.txt'))
  end

  test 'creates resources in db' do
    skip 'Too slow taking ~6s'
    assert_empty Provider.where(name: 'Microsoft Azure')

    AzureUpdater.new.perform

    provider = Provider.find_by(name: 'Microsoft Azure')
    assert_not_nil provider

    assert_not_empty provider.resources.where(resource_type: 'storage')
    assert_not_empty provider.resources.where(resource_type: 'compute')
  end

end
