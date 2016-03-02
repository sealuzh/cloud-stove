class AzureUpdater < ProviderUpdater
  def perform
    uri = URI('https://azure.microsoft.com/en-us/pricing/details/virtual-machines/')

    doc = Nokogiri::HTML(open(uri))

    pricelist = {}

    pricelist_pos = doc.css('[data-tab-panel="tab-panel-os"]').css('[data-href="#Linux"]').attribute('data-id').text
    pricelist_div = doc.css('[data-tab-panel-id="tab-panel-os"]').css("div:eq(#{pricelist_pos})")
    pricelist_entries = pricelist_div.css("table > tbody > tr")

    pricelist_entries.each do |tr|
      logger.info tr.to_s
      cells = tr.css('td')
      # Pricing table rows have 5 cells:
      # instance id, cores, ram, disk sizes, price
      next if cells.count < 5

      resource_id = cells.first.text.gsub(/\s/, '')
      amounts = JSON.load(cells[4].css('>span.price-data').attribute('data-amount').to_s)
      price_per_hour = amounts["default"]

      pricelist[resource_id] = {
        'type' => 'compute',
        'cores' => cells[1].css('strong').text,
        'mem_gb' => cells[2].css('strong').text,
        'price_per_hour' => price_per_hour,
      }
    end
    
    provider = Provider.find_or_create_by(name: 'Microsoft Azure')
    provider.more_attributes['pricelist'] = pricelist
    provider.more_attributes['sla'] = extract_sla('https://azure.microsoft.com/en-us/support/legal/sla/virtual-machines/v1_0/')
    provider.save!
    
    pricelist.each_pair do |resource_id, data|
      resource = provider.resources.find_or_create_by(name: resource_id)
      resource.more_attributes = data
      resource.save!
    end
  end
end
