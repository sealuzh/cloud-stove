class AmazonUpdater < ProviderUpdater
  def perform
    provider = update_provider
    update_compute(provider)
    update_storage(provider)
  end

  private

    # crawls all us-east-1 EC2 compute instances and their prices
    def update_compute(provider)
      response = make_request('https://a0.awsstatic.com/pricing/1/ec2/linux-od.min.js')
      pricelist = parse_callback(response.body)

      provider.more_attributes['pricelist'][:compute] = pricelist
      provider.save!

      # For now, get all instance types from first region (should be us-east-1)
      region = pricelist['config']['regions'].first
      region['instanceTypes'].each do |it|
        # type: generalCurrentGen, computeCurrentGen, gpuCurrentGen, hiMemCurrentGen, storageCurrentGen
        instance_type = it['type']
        it['sizes'].each do |s|
          # Attributes: size, vCPU, ECU, memoryGiB, storageGB, valueColumns
          resource_id = s['size']
          resource = provider.resources.find_or_create_by(name: resource_id)

          resource.resource_type = 'compute'
          resource.more_attributes['cores'] = s['vCPU']
          resource.more_attributes['mem_gb'] = BigDecimal.new(s['memoryGiB'])
          resource.more_attributes['price_per_hour'] = s['valueColumns'].first['prices']['USD']
          resource.save!
        end
      end
    rescue Net::HTTPError, JSON::ParserError => e
      logger.error "Error, #{e.inspect}"
    end


    # crawls all us-east-1 S3 storage instances and their prices
    def update_storage(provider)
      response = make_request('http://a0.awsstatic.com/pricing/1/s3/pricing-storage-s3.min.js')
      pricelist = parse_callback(response.body)

      provider.more_attributes['pricelist'][:storage] = pricelist
      region = pricelist['config']['regions'].first

      region['tiers'].first['storageTypes'].each do |storageType|
        resource_name = storageType['type']
        resource = provider.resources.find_or_create_by(name: resource_name)
        resource.resource_type = 'storage'
        resource.more_attributes['price_per_gb'] = storageType['prices']['USD']
        resource.save!
      end

    rescue Net::HTTPError, JSON::ParserError => e
      logger.error "Error, #{e.inspect}"
    end


    #update general Amazon provider data
    def update_provider
      provider = Provider.find_or_create_by(name: 'Amazon')

      sla_hash = {}
      sla_hash[:compute] = extract_sla('https://aws.amazon.com/ec2/sla/')
      sla_hash[:storage] = extract_sla('https://aws.amazon.com/s3/sla/');

      pricelist_hash = {}

      provider.more_attributes['sla'] = sla_hash;
      provider.more_attributes['pricelist'] = pricelist_hash
      provider.save!
      provider
    end

    # Makes an HTTP-GET request on the specified url and returns the response object
    def make_request(url)
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')

      response = http.get(uri.request_uri)

      # Raises error if response is not 2xx, see http://ruby-doc.org/stdlib-2.1.2/libdoc/net/http/rdoc/Net/HTTPResponse.html#method-i-value
      response.value

      response
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
