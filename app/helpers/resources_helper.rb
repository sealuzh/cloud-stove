module ResourcesHelper
  def price_per_core(resource)
    cores = resource.ma['cores'] == 'shared' ? 0.1 : resource.ma['cores']
    number_with_precision(resource.price_per_month / BigDecimal.new(cores.to_s), precision: 3)
  end
  
  def price_per_gb_ram(resource)
    number_with_precision(resource.price_per_month / BigDecimal.new(resource.ma['mem_gb'].to_s), precision: 3)
  end
end
