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

    pricelist['config']['regions'].each do |region_json|
      region = region_json['region']

      region_json['instanceTypes'].each do |it|

        instance_type = it['type']
        it['sizes'].each do |s|
          # Attributes: size, vCPU, ECU, memoryGiB, storageGB, valueColumns
          resource_id = s['size']
          resource = provider.resources.find_or_create_by(name: resource_id, region: region)

          resource.resource_type = 'compute'
          resource.more_attributes['cores'] = s['vCPU']
          resource.more_attributes['mem_gb'] = BigDecimal.new(s['memoryGiB'])
          resource.more_attributes['price_per_hour'] = s['valueColumns'].first['prices']['USD']
          resource.region = region
          resource.region_area = extract_region_area(region)
          resource.save!
        end
      end
    end

  rescue Net::HTTPError, JSON::ParserError => e
    logger.error "Error, #{e.inspect}"
  end


  def update_storage(provider)
    response = make_request('http://a0.awsstatic.com/pricing/1/s3/pricing-storage-s3.min.js')
    pricelist = parse_callback(response.body)


    provider.more_attributes['pricelist'][:storage] = pricelist
    provider.save!
    pricelist['config']['regions'].each do |region_json|
      region = region_json['region']

      region_json['tiers'].each do |tier|
        tier_name = tier['name']
        tier['storageTypes'].each do |storageType|
          storage_name = storageType['type']
          resource_name = tier_name + "_" + storage_name
          resource = provider.resources.find_or_create_by(name: resource_name, region: region)
          resource.resource_type = 'storage'
          resource.region = region
          resource.more_attributes['price_per_gb'] = storageType['prices']['USD']
          resource.region_area = extract_region_area(region)
          resource.save!
        end
      end

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


  def extract_region_area(region)
    if region.downcase().include? 'us'
      return 'US'
    elsif region.downcase().include? 'eu'
      return 'EU'
    elsif region.downcase().include? 'ap'
      return 'ASIA'
    elsif region.downcase().include? 'sa'
      return 'SA'
    end
  end

end
