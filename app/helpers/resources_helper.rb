module ResourcesHelper
  def price_per_core(resource, raw: false)
    cores = resource.ma['cores'] == 'shared' ? 0.1 : resource.ma['cores']
    ppc = resource.price_per_month / BigDecimal.new(cores.to_s)
    raw ? ppc : format_price(ppc)
  end
  
  def price_per_gb_ram(resource, raw: false)
    ppgr = resource.price_per_month / BigDecimal.new(resource.ma['mem_gb'].to_s)
    raw ? ppgr : format_price(ppgr, precision: 2)
  end
end
