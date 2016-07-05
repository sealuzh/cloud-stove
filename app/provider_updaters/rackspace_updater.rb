require 'open-uri'

class RackspaceUpdater < ProviderUpdater

  def perform
    doc = get_pricing_doc
    update_provider
    update_compute(doc)
    # update_storage(doc)
  end


  private

  def update_provider
    provider = Provider.find_or_create_by(name: 'Rackspace')
    provider.more_attributes['pricelist'] ||= {}
    provider.more_attributes['sla'] = {
        uri: 'https://www.rackspace.com/information/legal/cloud/sla'
    }
    provider.save!

  end

  def update_storage(doc)
    table = doc.css('div.horizontal-scroll')[4].css('.cloud-pricing-table')[0]
    resource_id = 'cloud-files'
    price_per_month_gb =  number_from(table.css('.pricing-col-monthly')[0])
    price_per_hour_gb = number_from(table.css('.pricing-col-hourly')[0])

    pricelist = {
        'type' => 'storage',
        'price_per_hour_gb' => price_per_hour_gb,
        'price_per_month_gb' => price_per_month_gb
    }

    provider = Provider.find_by(name: 'Rackspace')
    resource = provider.resources.find_or_create_by(name: resource_id)
    resource.more_attributes['price_per_hour_gb'] = price_per_hour_gb
    resource.more_attributes['price_per_month_gb'] = price_per_month_gb
    resource.resource_type = 'storage'
    resource.save!

    provider = Provider.find_by(name: 'Rackspace')
    provider.more_attributes['pricelist']['storage'] = pricelist
    provider.save!

  end

  def update_compute(doc)
    # Rackspace does not differentiate prices between different regions, hence the regions are not crawble from the pricing tables
    # We hardcode the regions here, taken from https://www.rackspace.com/about/datacenters

    regions = ['LON','SYD','DFW','IAD','ORD','HKG']

    pricelist = {}

    pricing_rows = doc.css('[data-currency="USD"]').css('.pricing-row-linux')
    pricing_rows.each do |row|
      data = row.css('td')
      resource_id = data[0].text
      price_per_hour = number_from(data.css('.pricing-col-raw.pricing-col-hourly'))
      price_per_hour += number_from(data.css('.pricing-col-inf.pricing-col-hourly'))
      price_per_month = number_from(data.css('.pricing-col-raw.pricing-col-monthly'))
      price_per_month += number_from(data.css('.pricing-col-inf.pricing-col-monthly'))
      pricelist[resource_id] = {
          'type' => 'compute',
          'mem_gb' => data[1].text.to_d.to_s,
          'cores' => data[2].text,
          'price_per_hour' => price_per_hour.to_s,
          'price_per_month' => price_per_month.to_s,
          'bandwidth_mbps' => number_from(data[5]).to_s,
      }
    end


    provider = Provider.find_by(name: 'Rackspace')
    provider.more_attributes['pricelist']['compute'] = pricelist
    provider.save!

    pricelist.each_pair do |resource_id, data|
      regions.each do |region|
        resource = provider.resources.find_or_create_by(name: resource_id, region: region)
        resource.region_code = provider.region_code(region)
        resource.region = region
        resource.region_area = extract_region_area(region)
        resource.more_attributes = data
        resource.resource_type = 'compute'
        resource.save!
      end
    end

  end

  def get_pricing_doc
    # Rackspace does not have a pricing API so we need to scrape their website.
    uri = URI('https://www.rackspace.com/cloud/public-pricing')
    doc = Nokogiri::HTML(open(uri))
    doc
  end


  def number_from(field)
    field.text.delete('^0-9.').to_d
  end

  def extract_region_area(region)
    if (region =='DFW') || (region == 'IAD') || (region == 'ORD')
      return 'US'
    elsif region == 'LON'
      return 'EU'
    elsif region =='HKG' || (region == 'SYD')
      return 'ASIA'
    end
  end

end