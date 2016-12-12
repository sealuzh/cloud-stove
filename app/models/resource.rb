class Resource < Base
  include DeterministicHash
  ma_accessor :cores, :bandwidth_mbps, :mem_gb, :price_per_month_gb
  belongs_to :provider
  before_create :generate_region_code
  before_create :generate_resource_code
  scope :compute, -> { where(resource_type: 'compute') }
  scope :region_area, ->(region_area) { where(region_area: region_area) }
  scope :provider_name, ->(provider_name) { where(provider_id: Provider.find_by_name(provider_name)) }

  validates :resource_type, presence: true

  def self.region_codes(region_area)
    Resource.region_area(region_area).select(:region, :provider_id).distinct.map do |resource|
      resource.provider.region_code(resource.region)
    end
  end

  def self.regions(region_area)
    Resource.region_area(region_area).select(:region).distinct.map(&:region)
  end

  def derive_region_code
    self.provider.region_code(self.region)
  end

  # Assuming that a resource is identified by the composite key:
  # 1) `region_code` (provider_name + region_name)
  # 2) region `name`
  def derive_resource_code
    resource_string = self.region_code.to_s + self.name.to_s
    deterministic_hash(resource_string)
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
    hash[:resource_code] = self.resource_code
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
      self.region_code = derive_region_code
    end

    def generate_resource_code
      self.resource_code = derive_resource_code
    end

    def compute_as_json(resource)
      hash = {}
      hash[:cores] = resource.cores.to_f
      hash[:mem_gb] = resource.mem_gb.to_f
      hash[:price_per_hour] = resource.price_per_hour.to_f
      hash[:price_per_month] = resource.price_per_month.to_f
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
