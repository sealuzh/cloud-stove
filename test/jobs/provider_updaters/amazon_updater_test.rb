require 'test_helper'

class AmazonUpdaterTest < ActiveJob::TestCase
  setup do
    WebMock.stub_request(:get, 'https://a0.awsstatic.com/pricing/1/ec2/linux-od.min.js').
        to_return(response_from('amazon-ec2-pricing.txt'))
    WebMock.stub_request(:get, 'https://aws.amazon.com/ec2/sla/').
        to_return(response_from('amazon-ec2-sla.txt'))
  end

  test 'creates resources in db' do
    assert_empty Provider.where(name: 'Amazon')

    AmazonUpdater.perform_now

    provider = Provider.find_by(name: 'Amazon')
    assert_not_nil provider
    assert_not_empty provider.resources
  end

end
