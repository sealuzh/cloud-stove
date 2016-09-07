class PreferredRegionAreaConstraint < Constraint
  def region_codes
    Resource.region_codes(self.preferred_region_area)
  end

  def region_areas
    Resource.regions(self.preferred_region_area)
  end

  def as_json(options={})
    hash = super
    hash[:ingredient_id] = self.ingredient.id
    hash[:preferred_region_area] = self.preferred_region_area
    hash
  end
end
