class AmazonUpdater < ProviderUpdater
  def perform
    uri = URI('https://a0.awsstatic.com/pricing/1/ec2/linux-od.min.js')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    response = http.get(uri.request_uri) 
    # Raise error if response is not 2xx, see http://ruby-doc.org/stdlib-2.1.2/libdoc/net/http/rdoc/Net/HTTPResponse.html#method-i-value
    response.value

    result = ''
    V8::Context.new(timeout: 1000) do |ctx|
      ctx['result'] = result
      ctx.eval('function callback(param) { return JSON.stringify(param); }')
      ctx.eval('result = ' + response.body)
      result = ctx['result']
    end
    
    pricelist = JSON.parse(result)
    provider = Provider.find_or_create_by(name: 'Amazon')
    provider.more_attributes['pricelist'] = pricelist
    provider.more_attributes['sla'] = extract_sla('https://aws.amazon.com/ec2/sla/')
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
        
        resource.more_attributes['type'] = 'compute'
        resource.more_attributes['cores'] = s['vCPU']
        resource.more_attributes['mem_gb'] = BigDecimal.new(s['memoryGiB'])
        resource.more_attributes['price_per_hour'] = s['valueColumns'].first['prices']['USD']
        resource.save!
      end
    end
  rescue Net::HTTPError, JSON::ParserError => e
    logger.error "Error, #{e.inspect}"
  end
end