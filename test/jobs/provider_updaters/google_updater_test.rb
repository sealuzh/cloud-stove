require 'test_helper'

class GoogleUpdaterTest < ActiveJob::TestCase
  setup do
    WebMock.stub_request(:get, 'https://cloudpricingcalculator.appspot.com/static/data/pricelist.json').
        to_return(response_from('google-pricing.txt'))

    # WebMock.stub_request(:get, 'https://cloud.google.com/compute/sla').
    #     to_return(response_from('google-compute-sla.txt'))
    #
    # WebMock.stub_request(:get, 'https://cloud.google.com/storage/sla').
    #     to_return(response_from('google-storage-sla.txt'))
  end

  test 'creates resources in db' do
    assert_empty Provider.where(name: 'Google')

    GoogleUpdater.perform_now

    provider = Provider.find_by(name: 'Google')
    assert_not_nil provider
    assert_equal 54, provider.resources.compute.count
    assert_equal 0, provider.resources.where(region_area: RegionArea::UNKNOWN).count

    # Assert that a sample resource is stored correctly
    g1_small = provider.resources.where(name: 'g1-small', region: 'europe').first
    assert_not_nil g1_small
    assert_equal ({ 'cores' => '0.5', 'mem_gb' => '1.7', 'price_per_hour' => '0.03', 'price_per_month' => '15.624' }), g1_small.more_attributes
    assert_equal 'EU', g1_small.region_area
  end
end
