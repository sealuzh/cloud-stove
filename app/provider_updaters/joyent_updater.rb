class JoyentUpdater < ProviderUpdater
  include RegionArea

  def initialize
    super
    @prefixes = {
        'us' => 'US',
        'eu' => 'EU',
    }
  end

  def perform
    update_provider
    update_compute_batch
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

    def update_compute_batch
      ActiveRecord::Base.transaction do
        update_compute
      end
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
          resource.region_area = extract_region_area(region)
          resource.save!
        end
      end
    end

    def update_storage
      provider = Provider.find_or_create_by(name: 'Joyent')
      uri = URI('https://www.joyent.com/pricing/manta')
      doc = Nokogiri::HTML(open(uri))

      rows = doc.css('tbody')[0].css('tr')
      rows.pop()

      # there is no region info on the crawled pricing site, hence we hardcode it. Taken from https://docs.joyent.com/public-cloud/data-centers
      regions = ['us-east-1','us-east-2','us-east-3','us-east-3b','us-sw-1','us-west-1','eu-ams-1']

      rows.each do |storage_element|
        regions.each do |region|
          resource_name = storage_element.css('td')[0].text
          resource = provider.resources.find_or_create_by(name: resource_name, region: region)
          resource.resource_type = 'storage'
          resource.region_area = extract_region_area(region)
          resource.more_attributes['price_per_month_gb'] = number_from(storage_element.css('td')[1].text)
          resource.save!
        end
      end
    end

    def number_from(string)
      Float(string.delete('^0-9.').to_d)
    end
end
