class DigitalOceanUpdater < ProviderUpdater
  include RegionArea

  def initialize
    super
    @prefixes = {
        'nyc' => 'US',
        'sfo' => 'US',
        'tor' => 'US',
        'lon' => 'EU',
        'fra' => 'EU',
        'ams' => 'EU',
        'sgp' => 'ASIA',
        'blr' => 'ASIA',
    }
  end

  def perform
    @provider = Provider.find_or_create_by(name: 'Digital Ocean')
    update_compute_batch
  end

  def update_compute_batch
    ActiveRecord::Base.transaction do
      update_compute
    end
  end

  def update_compute
    token = ENV['DIGITALOCEAN_TOKEN']
    uri = URI('https://api.digitalocean.com/v2/sizes')

    request = Net::HTTP::Get.new(uri)
    request['Authorization']="Bearer #{token}"
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') { |http| http.request(request) }
    response.value

    pricelist = JSON.parse(response.body)
    @provider.more_attributes['pricelist'] = pricelist
    @provider.save!

    pricelist['sizes'].each do |instance_type|
      resource_id = instance_type['slug']

      instance_type['regions'].each do |region|
        resource = @provider.resources.find_or_create_by(name: resource_id, region: region)

        resource.resource_type = 'compute'
        resource.more_attributes['cores'] = instance_type['vcpus']
        resource.more_attributes['mem_gb'] = BigDecimal.new(instance_type['memory']) / 1024
        resource.more_attributes['price_per_hour'] = instance_type['price_hourly']
        resource.more_attributes['price_per_month'] = instance_type['price_monthly']
        resource.region_area = extract_region_area(region)
        resource.save!
      end
    end
  end
end
