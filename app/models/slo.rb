class Slo < Base
  ma_accessor :value
  ma_accessor :metric
  ma_accessor :relation

  attr_accessor :_destroy
  belongs_to :concrete_component



  def human_metric
    I18n.t(ma['metric'], scope: 'slos.metrics')
  end
  
  def human_value
    I18n.t('.value_format', scope: 'slos.metrics', 
      value: ma['value'], unit: ma['unit'], currency: ma['currency'],
      interval: ma['interval']
    )
  end
end
