require 'v8'

class AmazonUpdater < ProviderUpdater
  include RegionArea

  def initialize
    super
    @prefixes = {
        'us' => 'US',
        'eu' => 'EU',
        'ap' => 'ASIA',
        'sa' => 'SA',
    }
  end

  def perform
    @provider = Provider.find_or_create_by(name: 'Amazon')
    update_compute_batch
  end

  private

    def update_compute_batch
      ActiveRecord::Base.transaction do
        update_compute
      end
    end

    def update_compute
      pricelist = parse_callback(get_ec2_pricelist)
      pricelist['config']['regions'].each do |region_json|
        region_json['instanceTypes'].each do |family|
          family['sizes'].each do |instance|
            create_instance(region_json['region'], instance)
          end
        end
      end

    rescue => e
      logger.error "Error updating Amzon EC2 resources, #{e.message}"
      raise e
    end

    def create_instance(region, instance)
      resource = @provider.resources.find_or_create_by(name: instance['size'], region: region)
      resource.resource_type = 'compute'
      resource.region = region
      resource.region_area = extract_region_area(region)
      resource.more_attributes['cores'] = instance['vCPU']
      resource.more_attributes['mem_gb'] = BigDecimal.new(instance['memoryGiB'])
      resource.more_attributes['price_per_hour'] = instance['valueColumns'].first['prices']['USD']
      resource.save!
    end

    def get_ec2_pricelist
      uri = URI('https://a0.awsstatic.com/pricing/1/ec2/linux-od.min.js')
      response = Net::HTTP.get_response(uri)
      # Raises error if response is not 2xx, see http://ruby-doc.org/stdlib-2.1.2/libdoc/net/http/rdoc/Net/HTTPResponse.html#method-i-value
      response.value
      response.body
    end

    # Parses a JS-callback object containing Amazons pricing data
    def parse_callback(callback)
      result = ''

      V8::Context.new(timeout: 1000) do |ctx|
        ctx['result'] = result
        ctx.eval('function callback(param) { return JSON.stringify(param); }')
        ctx.eval('result = ' + callback)
        result = ctx['result']
      end

      JSON.parse(result)
    end
end
