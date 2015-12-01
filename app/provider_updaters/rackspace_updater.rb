require 'open-uri'

class RackspaceUpdater < ProviderUpdater
  def perform
    # Rackspace does not have a pricing API so we need to scrape their website.
    uri = URI('http://www.rackspace.com/cloud/public-pricing')
    doc = Nokogiri::HTML(open(uri))
    
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

    provider = Provider.find_or_create_by(name: 'Rackspace')
    provider.more_attributes['pricelist'] = pricelist
    provider.save!
    
    pricelist.each_pair do |resource_id, data|
      resource = provider.resources.find_or_create_by(name: resource_id)
      resource.more_attributes = data
      resource.save!
    end
  end
  
  private
  def number_from(field)
    field.text.delete('^0-9.').to_d
  end
end