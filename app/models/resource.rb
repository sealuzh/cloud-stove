class Resource < Base
  ma_accessor :cores, :bandwidth_mbps, :mem_gb, :price_per_month_gb
  belongs_to :provider
  before_create :generate_region_code
  before_create :generate_resource_code
  scope :compute, -> { where(resource_type: 'compute') }
  scope :region_area, ->(region_area) { where(region_area: region_area) }

  validates :resource_type, presence: true

  def self.region_codes(region_area)
    Resource.region_area(region_area).select(:region, :provider_id).distinct.map do |resource|
      resource.provider.region_code(resource.region)
    end
  end

  def self.regions(region_area)
    Resource.region_area(region_area).select(:region).distinct.map(&:region)
  end

  def region_code
    self.provider.region_code(self.region)
  end

  def resource_code
    # Assuming that 1) `region_code` (provider + region) and 2) region name together identify a resource
    (self.region_code.to_s + self.name.to_s).hash
  end

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

    def generate_region_code
      self.region_code = region_code
    end

    def generate_resource_code
      self.resource_code = resource_code
    end

    def compute_as_json(resource)
      hash = {}
      hash[:cores] = resource.cores
      hash[:mem_gb] = resource.mem_gb
      hash[:price_per_hour] = resource.price_per_hour
      hash[:price_per_month] = resource.price_per_month
      hash[:region] = resource.region
      hash[:region_area] = resource.region_area
      hash[:bandwidth_mpbs] = resource.bandwidth_mbps if resource.bandwidth_mbps
      hash[:created_at] = resource.created_at
      hash[:updated_at] = resource.updated_at
      hash
    end

    def storage_as_json(resource)
      hash = {}
      hash[:price_per_month_gb] = resource.price_per_month_gb
      hash[:region] = resource.region
      hash[:region_area] = resource.region_area
      hash[:created_at] = resource.created_at
      hash[:updated_at] = resource.updated_at
      hash
    end
end
