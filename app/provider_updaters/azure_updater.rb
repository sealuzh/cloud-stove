require 'net/http'

class AzureUpdater < ProviderUpdater
  OS_FLAVOR = '-linux'
  REGION_AREA_PREFIXES = {
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

  def perform
    azure = Provider.find_or_create_by(name: 'Microsoft Azure')
    vm_json = get_vm_json
    create_compute_resources_batch(azure, vm_json)
  end

  def get_vm_json
    uri = URI('https://azure.microsoft.com/api/v1/pricing/virtual-machines/calculator/?culture=en-us')
    response = Net::HTTP.get_response(uri)
    # if response.is_a?(Net::HTTPSuccess)
    JSON.parse(response.body)
  end

  def create_compute_resources_batch(azure, vm_json)
    ActiveRecord::Base.transaction do
      create_compute_resources(azure, vm_json)
    end
  end

  def create_compute_resources(azure, vm_json)
    vm_json['offers'].each do |name, values|
      values['prices'].each do |region_os, price|
        if region_os.end_with?(OS_FLAVOR)
          region = region(region_os)
          resource = azure.resources.find_or_create_by(name: name, region: region)
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

  private

    def extract_region_area(region)
      REGION_AREA_PREFIXES.each do |prefix, region_area|
        return region_area if region.start_with?(prefix)
      end
      puts "WARNING: Could not match region `#{region}` to a region area.
                     Check `REGION_AREA_PREFIXES` in `AzureUpdater`!"
      'UNKNOWN'
    end
end
