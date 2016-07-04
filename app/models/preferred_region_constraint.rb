class PreferredRegionConstraint < Constraint
  belongs_to :ingredient

  def region_codes
    aws = Provider.find_by_name('Amazon')
    case self.preferred_region
      when 'US'
        %w(us-east-1 us-west-2 us-west-1).map { |r| aws.region_code(r) }
      when 'EU'
        %w(eu-west-1 eu-central-1).map { |r| aws.region_code(r) }
      when 'ASIA'
        %w(ap-southeast-1 ap-northeast-1 ap-southeast-2 ap-northeast-2).map { |r| aws.region_code(r) }
      when 'SA'
        %w(sa-east-1).map { |r| aws.region_code(r) }
      else
        []
    end
  end

  # TODO: Filter based on region code on every resource instead of hardcoding matching lists
  def self.region_from_area(area)
    case area
      when 'US'
        %w(us-east-1 us-west-2 us-west-1)
      when 'EU'
        %w(eu-west-1 eu-central-1)
      when 'ASIA'
        %w(ap-southeast-1 ap-northeast-1 ap-southeast-2 ap-northeast-2)
      when 'SA'
        %w(sa-east-1)
      else
        []
    end
  end

  def as_json(options={})
    hash = super
    hash[:ingredient_id] = self.ingredient.id
    hash[:preferred_region] = self.preferred_region
    hash
  end
end
