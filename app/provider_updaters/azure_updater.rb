require 'azure_mgmt_resources'
require 'azure_mgmt_compute'

class AzureUpdater < ProviderUpdater
  def perform
    azure = Provider.find_or_create_by(name: 'Microsoft Azure')
    create_compute_resources(azure)
    azure.save!
  end

  def create_compute_resources(provider)
    regions.each do |region|
      vm_sizes(region).each do |vm|
        create_compute_resource(provider, region, vm)
      end
    end
  end

  def create_compute_resource(provider, region, vm)
    resource = provider.resources.find_or_create_by(name: vm.name, region: region)
    resource.resource_type = 'compute'
    resource.region_area ='EU' # TODO: extract_region_area(region)
    resource.more_attributes = more_attributes(vm)
    resource.save!
  end

  def regions
    resource_client = Azure::ARM::Resources::ResourceManagementClient.new(credentials(app_token))
    resource_client.subscription_id = subscription_id
    providers_api = Azure::ARM::Resources::Providers.new(resource_client)
    provider_response = providers_api.get('Microsoft.Compute')
    provider_response.resource_types.detect { |resource_type| resource_type.resource_type == 'locations/vmSizes' }.locations
  end

  # Returns `Array<VirtualMachineSize>`
  # VirtualMachineSize: http://www.rubydoc.info/gems/azure_mgmt_compute/0.6.0/Azure/ARM/Compute/Models/VirtualMachineSize
  def vm_sizes(region)
    compute_client = Azure::ARM::Compute::ComputeManagementClient.new(credentials(app_token))
    compute_client.subscription_id = subscription_id
    vm_sizes_api = Azure::ARM::Compute::VirtualMachineSizes.new(compute_client)
    vm_sizes_api.list(region).value
  end

  def more_attributes(vm)
    {
        'cores' => vm.number_of_cores,
        'mem_gb' => vm.memory_in_mb.to_f / 1000,
        'price_per_hour' => '0.0065' # TODO: extract price !!!
    }
  end

  private

    def subscription_id
      subscription_id = ENV['AZURE_SUBSCRIPTION_ID']
      if subscription_id.nil?
        fail ArgumentError, "#{self.class.to_s} requires `AZURE_SUBSCRIPTION_ID` to be set"
      end
      subscription_id
    end

    def app_token
      MsRestAzure::ApplicationTokenProvider.new(
          ENV['AZURE_TENANT_ID'],
          ENV['AZURE_CLIENT_ID'],
          ENV['AZURE_CLIENT_SECRET']
      )
    end

    def credentials(provider)
      MsRest::TokenCredentials.new(provider)
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
