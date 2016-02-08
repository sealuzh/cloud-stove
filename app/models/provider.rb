class Provider < Base
  has_many :resources

  # Return availability of provider
  # if there is none, assume 0.95
  def availability
    if more_attributes['sla'] && more_attributes['sla']['availability']
      BigDecimal(more_attributes['sla']['availability'].to_s)
    else
      0.95
    end
  end

  def self.update_providers
    UpdateProvidersJob.perform_later
  end
end
