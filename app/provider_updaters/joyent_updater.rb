class JoyentUpdater < ProviderUpdater
  def perform
    uri = URI('https://www.joyent.com/assets/js/pricing.json')
    
    pricelist = JSON.load(open(uri))
    
    provider = Provider.find_or_create_by(name: 'Joyent')
    provider.more_attributes['pricelist'] = pricelist
    provider.save!
    
    pricelist['Portfolio'].each do |instance_type|
      # For now, we only store VM types, no containers
      next unless instance_type['OS'] == 'Hardware VM'
      
      resource_id = instance_type['API Name']
      resource = provider.resources.find_or_create_by(name: resource_id)
      resource.more_attributes['type'] = 'compute'
      resource.more_attributes['price_per_hour'] = instance_type['Price']
      resource.more_attributes['cores'] = instance_type['vCPUs']
      resource.more_attributes['mem_gb'] = instance_type['RAM GiB']
      resource.more_attributes['bandwidth_gbps'] = instance_type['Network']
      resource.save!
    end
  end
end
