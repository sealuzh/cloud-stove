class Resource < Base
  belongs_to :provider
  has_and_belongs_to_many :deployment_recommendations
  
  def is_compute?
    more_attributes['type'] == 'compute'
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
