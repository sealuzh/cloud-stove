class JoyentUpdater < ProviderUpdater
  def perform
    update_provider
    update_compute
    update_storage
  end


  private

    def update_provider
      #TODO:  Add SLA for provider. CAUTION! Joyent has no 'actual' availability SLA, they claim 100%, but in reality it's around 0.9993, if you follow their example.
      # See here: https://www.joyent.com/about/policies/cloud-hosting-service-level-agreement

      provider = Provider.find_or_create_by(name: 'Joyent')
      provider.more_attributes['pricelist'] = {}
      provider.save!
    end

    def update_compute
      uri = URI('https://www.joyent.com/assets/js/pricing.json')

      pricelist = JSON.load(open(uri))

      provider = Provider.find_or_create_by(name: 'Joyent')
      provider.more_attributes['pricelist']['compute'] = pricelist
      provider.save!

      pricelist['Portfolio'].each do |instance_type|
        # For now, we only store VM types, no containers
        next unless instance_type['OS'] == 'Hardware VM'

        resource_id = instance_type['API Name']
        resource = provider.resources.find_or_create_by(name: resource_id)
        resource.resource_type = 'compute'
        resource.more_attributes['price_per_hour'] = instance_type['Price']
        resource.more_attributes['cores'] = instance_type['vCPUs']
        resource.more_attributes['mem_gb'] = instance_type['RAM GiB']
        resource.more_attributes['bandwidth_gbps'] = instance_type['Network']
        resource.save!

      end

    end

    def update_storage
      provider = Provider.find_or_create_by(name: 'Joyent')

      uri = URI('https://www.joyent.com/object-storage/pricing')
      doc = Nokogiri::HTML(open(uri))

      storage_div = doc.css('div#storage')

      pricelist = {}

      storage_div.css('table').css('thead').css('tr').css('th').each_with_index do |resource_name, index|
        next if (index==0)

        resource = provider.resources.find_or_create_by(name: resource_name.text)
        resource.resource_type = 'storage'
        resource.more_attributes['price_per_month_gb'] = storage_div.css('table').css('tbody').css('tr')[0].css('td')[index].text.delete('^0-9.').to_d
        resource.save!

        pricelist[resource.name] = {
            'type' => 'storage',
            'price_per_month_gb' => resource.more_attributes['price_per_month_gb']
        }
      end

      provider.more_attributes['pricelist']['storage'] = pricelist
      provider.save!


    end
end
