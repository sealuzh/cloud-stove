class Slo < Base

  attr_accessor :_destroy
  belongs_to :concrete_component


  def more_attributes=(attribute)
    if attribute.is_a?(Hash)
      write_attribute(:more_attributes, attribute)
    else
      write_attribute(:more_attributes, ActiveSupport::JSON.decode(attribute))
    end
  end

  def more_attributes
    read_attribute(:more_attributes).to_json
  end

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
