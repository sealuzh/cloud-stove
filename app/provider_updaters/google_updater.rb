class GoogleUpdater < ProviderUpdater
  include RegionArea

  def initialize
    super
    @prefixes = {
        'us' => 'US',
        'europe' => 'EU',
        'asia' => 'ASIA',
    }
  end

  def perform
    pricelist = update_provider
    update_compute_batch(pricelist)
    # update_storage(pricelist)
  end

  private

    def update_provider
      uri = URI('https://cloudpricingcalculator.appspot.com/static/data/pricelist.json')

      pricelist = JSON.load(open(uri))

      provider = Provider.find_or_create_by(name: 'Google')
      provider.more_attributes['pricelist'] = pricelist
      provider.more_attributes['sla'] = {}
      # provider.more_attributes['sla']['compute'] = extract_sla('https://cloud.google.com/compute/sla')
      # provider.more_attributes['sla']['storage'] = extract_sla('https://cloud.google.com/storage/sla',%r{(\d+(?:\.\d+)?)%}im)
      provider.save!
      pricelist
    end

    def update_compute_batch(pricelist)
      ActiveRecord::Base.transaction do
        update_compute(pricelist)
      end
    end

    def update_compute(pricelist)
      provider = Provider.find_or_create_by(name: 'Google')

      gcp_price_list = pricelist['gcp_price_list']
      sustained_base = BigDecimal.new(gcp_price_list['sustained_use_base'].to_s)
      sustained_tier_values = gcp_price_list['sustained_use_tiers'].values
      full_month_discount = sustained_tier_values.inject(0) do |sum, n|
        sum + BigDecimal.new(n.to_s) * sustained_base
      end

      gce_prefix = 'cp-computeengine-vmimage-'
      preemptible_postfix = '-preemptible'
      gcp_price_list.each_pair do |key, value|
        resource_id = key.downcase
        next unless resource_id.start_with? gce_prefix
        preemptible = resource_id.end_with?(preemptible_postfix)
        resource_id.gsub!(/(#{gce_prefix}|#{preemptible_postfix})/, '')

        next if preemptible
        regions = ['europe','us','asia']
        regions.each do |region|
          resource = provider.resources.find_or_create_by(name: resource_id, region:region)
          resource.more_attributes['price_per_hour'] = value[region].to_s
          # NOTICE: 744 hours/month assumes a 31 day month. Same as above.
          price_per_month = BigDecimal.new(value[region].to_s) * 744 * full_month_discount
          resource.more_attributes['price_per_month'] = price_per_month
          # vCPU Quotas from https://cloud.google.com/compute/pricing#sharedcore
          resource.more_attributes['cores'] = case resource_id 
          when 'f1-micro'
            '0.2'
          when 'g1-small'
            '0.5'
          else
            value['cores']
          end
          resource.more_attributes['mem_gb'] = value['memory']
          resource.resource_type = 'compute'
          resource.region_area = extract_region_area(region)
          resource.save!
        end
      end
    end

    def update_storage(pricelist)
      bigstore_storage_prefix = 'CP-BIGSTORE-STORAGE'
      nearline_storage_prefix = 'CP-NEARLINE-STORAGE'

      provider = Provider.find_or_create_by(name: 'Google')

      gcp_price_list = pricelist['gcp_price_list']

      gcp_price_list.each_pair do |key, value|
        next unless ((key.start_with? bigstore_storage_prefix) || (key.start_with? nearline_storage_prefix))

        region = 'us'
        resource = provider.resources.find_or_create_by(name: key, region: region)
        resource.resource_type = 'storage'
        resource.region_area = extract_region_area(region)
        resource.more_attributes['price_per_month_gb'] = value[region]
        resource.save!

      end
    end
end
