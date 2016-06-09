class Resource < Base
  ma_accessor :cores, :bandwidth_mbps, :mem_gb, :price_per_month_gb
  belongs_to :provider
  scope :compute, -> { where(resource_type: 'compute') }

  validates :resource_type, presence: true
  
  def is_compute?
    resource_type == 'compute'
  end
  
  def price_per_month
    if more_attributes['price_per_month']
      BigDecimal.new(more_attributes['price_per_month'].to_s)
    else
      price_per_hour * 744
    end
  end
  
  def price_per_hour
    BigDecimal.new(more_attributes['price_per_hour'].to_s || 0)
  end

  def as_json(options={})
    hash = {}
    hash[:id] = self.id
    hash[:resource_type] = self.resource_type
    hash[:name] = self.name
    hash[:provider] = self.provider.name

    params = case self.resource_type
                 when 'compute'
                   compute_as_json(self)

                 when 'storage'
                   storage_as_json(self)
               end
    hash = hash.merge(params)
    hash
  end

  private

    def compute_as_json(resource)
      hash = {}
      hash[:cores] = resource.cores
      hash[:mem_gb] = resource.mem_gb
      hash[:price_per_hour] = resource.price_per_hour
      hash[:price_per_month] = resource.price_per_month
      hash[:bandwidth_mpbs] = resource.bandwidth_mbps unless !resource.bandwidth_mbps
      hash[:created_at] = resource.created_at
      hash[:updated_at] = resource.updated_at
      hash
    end

    def storage_as_json(resource)
      hash = {}
      hash[:price_per_month_gb] = resource.price_per_month_gb
      hash[:created_at] = resource.created_at
      hash[:updated_at] = resource.updated_at
      hash
    end
end
