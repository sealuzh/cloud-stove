class AtlanticNetUpdater < ProviderUpdater
  include RegionArea

  def initialize
    super
    @prefixes = {
        'US' => 'US',
        'CA' => 'US',
        'EU' => 'EU',
    }
  end

  # Get pricing data from Atlantic.net API
  # see https://www.atlantic.net/docs/api/#describe-plans
  def perform
    @provider = Provider.find_or_create_by(name: 'Atlantic.net')
    update_compute_batch
  end

  def update_compute_batch
    ActiveRecord::Base.transaction do
      update_compute
    end
  end

  # Atlantic.Net API docs: https://www.atlantic.net/docs/api/?shell#describe-plans
  def update_compute
    uri = URI('https://cloudapi.atlantic.net/?Action=describe-plan')
    access_key_id = ENV['ANC_ACCESS_KEY_ID']
    private_key = ENV['ANC_PRIVATE_KEY']

    if access_key_id.nil? || private_key.nil?
      raise ArgumentError, "#{self.class.to_s} requires ANC_ACCESS_KEY_ID and ANC_PRIVATE_KEY to be set."
    end

    version = '2010-12-30'
    format = 'json'
    timestamp = Time.now.to_i
    rndguid = SecureRandom.uuid
    signature = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), private_key, "#{timestamp}#{rndguid}")
    platform = 'linux'

    request = Net::HTTP::Post.new(uri)
    request.set_form_data(
        'Version' => version,
        'ACSAccessKeyId' => access_key_id,
        'Format' => format,
        'Timestamp' => timestamp,
        'Rndguid' => rndguid,
        'Signature' => Base64.strict_encode64(signature),
    )
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') { |http| http.request(request) }
    response.value

    response_json = JSON.parse(response.body)
    raise ProviderUpdater::Error.new(response_json['error']) if response_json['error']

    pricelist = response_json['describe-planresponse']['plans']

    @provider.more_attributes['pricelist'] = pricelist
    @provider.more_attributes['sla'] = {
        uri: 'https://www.atlantic.net/service-policies/cloud-service-level-agreement/',
        availability: '1'
    }
    @provider.save!

    pricelist.each_pair do |key, instance_type|
      next unless instance_type['platform'] == platform
      resource_id = instance_type['plan_name']

      # NOTICE: Currently hardcoded data center list. Looks like pricing is identical for all regions:
      # https://www.atlantic.net/cloud-hosting/pricing/
      regions = ['EUWEST1', 'USEAST1', 'USEAST2', 'USCENTRAL1', 'USWEST1', 'CAEAST1']

      regions.each do |region|
        resource = @provider.resources.find_or_create_by(name: resource_id, region: region)

        resource.resource_type = 'compute'
        resource.more_attributes['cores'] = instance_type['num_cpu']
        resource.more_attributes['mem_gb'] = BigDecimal.new(instance_type['ram'].to_s) / 1024
        resource.more_attributes['price_per_hour'] = BigDecimal.new(instance_type['rate_per_hr'].to_s)
        resource.more_attributes['os_platform'] = instance_type['platform']
        resource.more_attributes['bandwidth_mbps'] = instance_type['bandwidth']
        resource.region_area = extract_region_area(region)
        resource.save!
      end
    end
  end
end
