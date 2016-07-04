class JoyentUpdater < ProviderUpdater
  def perform
    update_provider
    update_compute
    # update_storage
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
    provider = Provider.find_or_create_by(name: 'Joyent')
    uri = URI('https://www.joyent.com/pricing')
    doc = Nokogiri::HTML(open(uri))
    # there is no region info on the crawled pricing site, hence we hardcode it. Taken from https://docs.joyent.com/public-cloud/data-centers
    regions = ['us-east-1','us-east-2','us-east-3','us-east-3b','us-sw-1','us-west-1','eu-ams-1']
    kvm_div = doc.css('div#kvm')
    instances = kvm_div.css('div.instance')

    instances.each do |instance_element|

      if number_from(instance_element.css('li.spec.cpu').text) < 1
        next
      end
      regions.each do |region|
        resource_name = instance_element.css('li.spec.api').text

        resource = provider.resources.find_or_create_by(name: resource_name, region: region)
        resource.more_attributes['price_per_hour'] = number_from(instance_element.css('p.pph.s')[0].text)
        resource.more_attributes['price_per_month'] = number_from(instance_element.css('p.pph.s')[1].text)
        resource.more_attributes['cores'] = number_from(instance_element.css('li.spec.cpu').text)
        resource.more_attributes['mem_gb'] = number_from(instance_element.css('li.spec.ram').text)
        resource.more_attributes['disk_gb'] = number_from(instance_element.css('li.spec.disk').text)
        resource.resource_type = 'compute'
        resource.region_code = provider.region_code(region)
        resource.save!
      end
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


    def number_from(string)
      Float(string.delete('^0-9.').to_d)
    end
end
