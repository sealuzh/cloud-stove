class GoogleUpdater < ProviderUpdater
  def perform
    uri = URI('https://cloudpricingcalculator.appspot.com/static/data/pricelist.json')
    
    pricelist = JSON.load(open(uri))
    
    provider = Provider.find_or_create_by(name: 'Google')
    provider.more_attributes['pricelist'] = pricelist
    provider.more_attributes['sla'] = extract_sla('https://cloud.google.com/compute/sla')
    provider.save!
    
    gcp_price_list = pricelist['gcp_price_list']
    sustained_base = BigDecimal.new(gcp_price_list['sustained_use_base'].to_s)
    sustained_tier_values = gcp_price_list['sustained_use_tiers'].values
    full_month_discount = sustained_tier_values.inject(0) do |sum, n| 
      sum + BigDecimal.new(n.to_s) * sustained_base 
    end
    
    gce_prefix = 'cp-computeengine-vmimage-'
    preemptible_postfix = '-preemptible'
    gcp_price_list.each_pair do |key, value|
      resource_id = key.downcase
      next unless resource_id.start_with? gce_prefix
      preemptible = resource_id.end_with?(preemptible_postfix)
      resource_id.gsub!(/(#{gce_prefix}|#{preemptible_postfix})/, '')
      
      next if preemptible
      resource = provider.resources.find_or_create_by(name: resource_id)
      resource.more_attributes['type'] = 'compute'
      # FIXME: For now, use prices for instances in Europe. They're more
      # expensive. Better for conservative estimates. Should eventually
      # include all regions
      resource.more_attributes['price_per_hour'] = value['europe']
      # FIXME: 744 hours/month assumes a 31 day month. Same as above.
      price_per_month = BigDecimal.new(value['europe'].to_s) * 744 * full_month_discount
      resource.more_attributes['price_per_month'] = price_per_month
      resource.more_attributes['cores'] = value['cores']
      resource.more_attributes['mem_gb'] = value['memory']
      resource.save!
    end
  rescue Net::HTTPError, JSON::ParserError => e
    logger.error "Error, #{e.inspect}"
  end
end
