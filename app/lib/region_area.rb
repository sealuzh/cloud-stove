# Define the region area mappings in a constant called
# `RegionArea::PREFIXES` as for example:
# include RegionArea
# RegionArea::PREFIXES = {
#     'us' => 'US',
#     'eu' => 'EU',
# }
module RegionArea
  UNKNOWN = 'UNKNOWN'
  def extract_region_area(region)
    PREFIXES.each do |prefix, region_area|
      return region_area if region.start_with?(prefix)
    end
    puts "WARNING: Could not match region `#{region}` to a region area. Check `PREFIXES` in `#{self.class}`!"
    UNKNOWN
  end
end
