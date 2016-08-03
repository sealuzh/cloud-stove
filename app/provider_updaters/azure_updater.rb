class AzureUpdater < ProviderUpdater
  def perform
    update_provider
    update_compute
    update_storage
  end

  private

    def update_provider
      provider = Provider.find_or_create_by(name: 'Microsoft Azure')
      provider.more_attributes['pricelist'] = {}
      provider.more_attributes['sla'] = {}
      provider.more_attributes['sla']['storage'] = extract_sla('https://azure.microsoft.com/en-us/support/legal/sla/storage/v1_0/')
      provider.more_attributes['sla']['compute'] = extract_sla('https://azure.microsoft.com/en-us/support/legal/sla/virtual-machines/v1_0/')
      provider.save!
    end


    def update_compute
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
        price_data_span = cells[4].css('>span.price-data')
        next if price_data_span.empty?
        data_amount_value = price_data_span.attribute('data-amount')
        amounts = JSON.load(data_amount_value.to_s)
        next unless amounts.is_a?(Hash)
        price_per_hour = amounts["default"]
        pricelist[resource_id] = {
            'type' => 'compute',
            'cores' => cells[1].css('strong').text,
            'mem_gb' => cells[2].css('strong').text,
            'price_per_hour' => price_per_hour,
            'regions' => amounts['regional'],
        }
      end
      provider = Provider.find_or_create_by(name: 'Microsoft Azure')
      provider.more_attributes['pricelist']['compute'] = pricelist
      provider.save!
      pricelist.each_pair do |resource_id, data|
        data['regions'].each do |region, price|
          resource = provider.resources.find_or_create_by(name: resource_id, region: region)
          resource.resource_type = 'compute'
          resource.more_attributes = data.except('type')
          resource.more_attributes['price_per_hour'] = price
          resource.region_area = extract_region_area(region)
          resource.save!
        end
      end
    end


    def update_storage
      uri = URI('https://azure.microsoft.com/en-us/pricing/details/storage/')
      doc = Nokogiri::HTML(open(uri))
      pricelist = {}
      provider = Provider.find_or_create_by(name: 'Microsoft Azure')
      blob_storage_div = doc.css('div.wa-content.wa-tabs-container.wa-conditionalDisplay')[0]
      first_tb_prices = blob_storage_div.css('tbody').css('tr').css('td')
      blob_storage_div.css('thead').css('th').each_with_index do |resource_name,index |
        next if resource_name.text == ''
        #skip the first tablehead since that is the description column
        next unless (index != 0) && (!first_tb_prices[index].children.first.attributes['data-amount'].nil?)

        region_hash = JSON.parse(first_tb_prices[index].children.first.attributes['data-amount'].value)
        region_hash['regional'].each do |region,price|
          resource = provider.resources.find_or_create_by(name: resource_name.text, region: region)
          resource.resource_type = 'storage'
          resource.region_area = extract_region_area(region)
          resource.more_attributes['price_per_month_gb'] = price
          resource.save!
          pricelist[resource_name.text] = {
              'type' => 'storage',
              'price_per_month_gb' => resource.more_attributes['price_per_month_gb']
          }
        end
      end
      provider.more_attributes['pricelist']['storage'] = pricelist
      provider.save!
    end

    def extract_region_area(region)
      if (region.downcase().include? 'us-') || (region.downcase().include? 'canada') || (region.downcase().include? 'usgov')
        return 'US'
      elsif (region.downcase().include? 'eu') || (region.downcase().include? 'europe')
        return 'EU'
      elsif (region.downcase().include? 'australia') || (region.downcase().include? 'japan') || (region.downcase().include? 'asia') || (region.downcase().include? 'india')
        return 'ASIA'
      elsif region.downcase().include? 'brazil'
        return 'SA'
      end
    end
end
