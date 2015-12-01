class GoogleUpdater < ProviderUpdater
  def perform
    uri = URI('https://cloudpricingcalculator.appspot.com/static/data/pricelist.json')
    http = Net::HTTP.new(uri.host, uri.port, use_ssl: uri.scheme == 'https')
    response = http.get(uri.request_uri) 
    # Raise error if response is not 2xx, see http://ruby-doc.org/stdlib-2.1.2/libdoc/net/http/rdoc/Net/HTTPResponse.html#method-i-value
    response.value
    
    pricelist = JSON.parse(response.body)
    
    provider = Provider.find_or_create_by(name: 'Google')
    if pricelist['version'] != (provider.more_attributes['pricelist']['version'] rescue false)
      logger.info "Storing new price list #{pricelist['version']}."
      provider.more_attributes['pricelist'] = pricelist
      provider.save!
    end
    
    gce_prefix = 'cp-computeengine-vmimage-'
    preemptible_postfix = '-preemptible'
    pricelist['gcp_price_list'].each_pair do |key, value|
      resource_id = key.downcase
      next unless resource_id.start_with? gce_prefix
      preemptible = resource_id.end_with?(preemptible_postfix)
      resource_id.gsub!(/(#{gce_prefix}|#{preemptible_postfix})/, '')
      
      next if preemptible
      resource = provider.resources.find_or_create_by(name: resource_id)
      resource.more_attributes['type'] = 'compute'
      resource.more_attributes['price_per_hour'] = value['us']
      resource.more_attributes['cores'] = value['cores']
      resource.more_attributes['mem_gb'] = value['memory']
      resource.save!
    end
  rescue Net::HTTPError, JSON::ParserError => e
    logger.error "Error, #{e.inspect}"
  end
end
