class Resource < Base
  ma_accessor :cores, :type, :bandwidth_mbps, :mem_gb
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
end
