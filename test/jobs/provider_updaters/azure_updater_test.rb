require 'test_helper'

class AzureUpdaterTest < ActiveJob::TestCase
  setup do
    WebMock.stub_request(:get, 'https://azure.microsoft.com/api/v1/pricing/virtual-machines/calculator/?culture=en-us').
        to_return(body: response_from('azure-pricing.txt'), status: 200)
  end

  test 'creates resources in db' do
    skip 'Too slow taking ~3s'
    assert_empty Provider.where(name: 'Microsoft Azure')

    AzureUpdater.new.perform

    # Assert that resources are present
    provider = Provider.find_by(name: 'Microsoft Azure')
    assert_not_nil provider
    assert_equal 878, provider.resources.where(resource_type: 'compute').count
    assert_equal 0, provider.resources.where(region_area: RegionArea::UNKNOWN).count

    # Assert that a sample resource is stored correctly
    standard_a0 = provider.resources.where(name: 'standard-a0', region: 'us-east').first
    assert_not_nil standard_a0
    assert_equal ({'cores' => '1', 'mem_gb' => '0.75', 'price_per_hour' => '0.02'}), standard_a0.more_attributes
    assert_equal 'US', standard_a0.region_area
  end
end
