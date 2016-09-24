require 'test_helper'

class DigitalOceanUpdaterTest < ActiveJob::TestCase
  setup do
    WebMock.stub_request(:get, 'https://api.digitalocean.com/v2/sizes').
        to_return(response_from('digital-ocean-pricing.txt'))
  end

  test 'creates resources in db' do
    assert_empty Provider.where(name: 'Digital Ocean')

    DigitalOceanUpdater.perform_now

    provider = Provider.find_by(name: 'Digital Ocean')
    assert_not_nil provider
    assert_equal 0, provider.resources.where(region_area: RegionArea::UNKNOWN).count
    assert_equal 96, provider.resources.compute.count
  end
end
