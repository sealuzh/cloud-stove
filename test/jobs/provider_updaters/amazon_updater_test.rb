require 'test_helper'

class AmazonUpdaterTest < ActiveJob::TestCase
  setup do
    WebMock.stub_request(:get, 'https://a0.awsstatic.com/pricing/1/ec2/linux-od.min.js').
        to_return(response_from('amazon-ec2-pricing.txt'))
  end

  test 'creates resources in db' do
    assert_empty Provider.where(name: 'Amazon')

    AmazonUpdater.perform_now

    # Assert that resources are present
    provider = Provider.find_by(name: 'Amazon')
    assert_not_nil provider
    assert_equal 428, provider.resources.compute.count
    assert_equal 0, provider.resources.where(region_area: RegionArea::UNKNOWN).count

    # Assert that a sample resource is stored correctly
    t2_nano = provider.resources.where(name: 't2.nano', region: 'eu-central-1').first
    assert_not_nil t2_nano
    assert_equal ({ 'cores' => '0.05', 'mem_gb' => '0.5', 'price_per_hour' => '0.0075' }), t2_nano.more_attributes
    assert_equal 'EU', t2_nano.region_area
  end
end
