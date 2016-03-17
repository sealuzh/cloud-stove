class DigitalOceanUpdater < ProviderUpdater
  def perform
    token = ENV['DIGITALOCEAN_TOKEN']
    uri = URI("https://api.digitalocean.com/v2/sizes")
    
    request = Net::HTTP::Get.new(uri)
    request['Authorization']="Bearer #{token}"
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') { |http| http.request(request) }
    response.value
    
    pricelist = JSON.parse(response.body)
    provider = Provider.find_or_create_by(name: 'Digital Ocean')
    provider.more_attributes['pricelist'] = pricelist
    provider.save!
    
    pricelist['sizes'].each do |instance_type|
      resource_id = instance_type['slug']
      resource = provider.resources.find_or_create_by(name: resource_id)
      
      resource.resource_type = 'compute'
      resource.more_attributes['cores'] = instance_type['vcpus']
      resource.more_attributes['mem_gb'] = BigDecimal.new(instance_type['memory']) / 1024
      resource.more_attributes['price_per_hour'] = instance_type['price_hourly']
      resource.more_attributes['price_per_month'] = instance_type['price_monthly']
      resource.save!
    end
  rescue Net::HTTPError, JSON::ParserError => e
    logger.error "Error, #{e.inspect}"
  end
end
