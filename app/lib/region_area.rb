# Define the region area mappings in a field called `prefixes`
# Example:
# include RegionArea
# def initialize
#   super
#   @prefixes = {
#       'us' => 'US',
#       'eu' => 'EU',
#   }
# end
module RegionArea
  UNKNOWN = 'UNKNOWN'
  def extract_region_area(region)
    @prefixes.each do |prefix, region_area|
      return region_area if region.start_with?(prefix)
    end
    puts "WARNING: Could not match region `#{region}` to a region area. Check `PREFIXES` in `#{self.class}`!"
    UNKNOWN
  end
end
