require 'net/http'

class AzureUpdater < ProviderUpdater
  OS_FLAVOR = '-linux'
  include RegionArea

  def initialize
    super
    @prefixes = {
        'us' => 'US',
        'canada' => 'US',
        'usgov' => 'US',
        'europe' => 'EU',
        'united-kingdom' => 'EU',
        'asia' => 'ASIA',
        'japan' => 'ASIA',
        'australia' => 'ASIA',
        'central-india' => 'ASIA',
        'south-india' => 'ASIA',
        'brazil' => 'SA'
    }
  end

  def perform
    @provider = Provider.find_or_create_by(name: 'Microsoft Azure')
    vm_json = get_vm_json
    update_compute_batch(vm_json)
  end

  def get_vm_json
    uri = URI('https://azure.microsoft.com/api/v1/pricing/virtual-machines/calculator/?culture=en-us')
    response = Net::HTTP.get_response(uri)
    # Raises error if response is not 2xx, see http://ruby-doc.org/stdlib-2.1.2/libdoc/net/http/rdoc/Net/HTTPResponse.html#method-i-value
    response.value
    JSON.parse(response.body)
  end

  # Using a transaction speeds up creating 878 resources by about 1 second
  def update_compute_batch(vm_json)
    ActiveRecord::Base.transaction do
      update_compute(vm_json)
    end
  end

  def update_compute(vm_json)
    vm_json['offers'].each do |name, values|
      values['prices'].each do |region_os, price|
        if region_os.end_with?(OS_FLAVOR)
          region = region(region_os)
          resource = @provider.resources.find_or_create_by(name: name, region: region)
          resource.resource_type = 'compute'
          resource.region_area = extract_region_area(region)
          resource.more_attributes = {
              'cores' => values['cores'].to_s,
              'mem_gb' => values['ram'].to_s,
              'price_per_hour' => price.to_s
          }
          resource.save!
        end
      end
    end
  end

  def region(region_os)
    region_os.chomp(OS_FLAVOR)
  end
end
