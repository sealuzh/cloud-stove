require 'test_helper'

class AmazonUpdaterTest < ActiveJob::TestCase
  setup do

    #EC2 compute
    WebMock.stub_request(:get, 'https://a0.awsstatic.com/pricing/1/ec2/linux-od.min.js').
        to_return(response_from('amazon-ec2-pricing.txt'))
    WebMock.stub_request(:get, 'https://aws.amazon.com/ec2/sla/').
        to_return(response_from('amazon-ec2-sla.txt'))

    #S3 storage
    WebMock.stub_request(:get, 'http://a0.awsstatic.com/pricing/1/s3/pricing-storage-s3.min.js').
        to_return(response_from('amazon-s3-storage-pricing.txt'))
    WebMock.stub_request(:get, 'https://aws.amazon.com/s3/sla/').
        to_return(response_from('amazon-s3-sla.txt'))

  end

  test 'creates resources in db' do
    assert_empty Provider.where(name: 'Amazon')

    AmazonUpdater.perform_now

    provider = Provider.find_by(name: 'Amazon')
    assert_not_nil provider
    assert_not_empty provider.resources.where(resource_type: 'compute')
    assert_not_empty provider.resources.where(resource_type: 'storage')
  end

end
