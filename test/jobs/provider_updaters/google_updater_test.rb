require 'test_helper'

class GoogleUpdaterTest < ActiveJob::TestCase
  setup do
    WebMock.stub_request(:get, 'https://cloudpricingcalculator.appspot.com/static/data/pricelist.json').
        to_return(response_from('google-compute-pricing.txt'))
    WebMock.stub_request(:get, 'https://cloud.google.com/compute/sla').
        to_return(response_from('google-compute-sla.txt'))
  end

  test 'creates resources in db' do
    assert_empty Provider.where(name: 'Google')

    GoogleUpdater.perform_now

    provider = Provider.find_by(name: 'Google')
    assert_not_nil provider
    assert_not_empty provider.resources
  end

end
