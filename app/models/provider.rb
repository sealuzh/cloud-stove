class Provider < Base
  include DeterministicHash
  has_many :resources, dependent: :destroy

  # Return availability of provider
  # if there is none, assume 0.95
  def availability
    if more_attributes['sla'] && more_attributes['sla']['availability']
      BigDecimal(more_attributes['sla']['availability'].to_s)
    else
      0.95
    end
  end

  # Assuming that a region is identified by the composite key:
  # 1) `provider_name`
  # 2) `region_name`
  def region_code(region_name)
    region_string = self.name.to_s + region_name.to_s
    deterministic_hash(region_string)
  end

  def self.update_providers
    UpdateProvidersJob.perform_later
  end
end
