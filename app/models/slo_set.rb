# This model represents component SLOs
#
# An SLO always starts with an objective metric and a relation, e.g.
# `"availability": { "$gte": 0.995 }`.
# Additionally, it may contain further qualifiers, such as unit, currency,
# or interval specifications.
#
class SloSet < Base

  attr_accessor :_destroy
  belongs_to :concrete_component
  has_many :deployment_recommendations, autosave: true, dependent: :destroy
  ma_accessor :availability
  ma_accessor :costs


  def humanize
    humanized = more_attributes.map do |slo_attributes|
      humanize_slo(slo_attributes)
    end
  end
  
  def humanize_slo(slo_attributes)
    key, values = slo_attributes
    values = [ values ] unless values.is_a?(Array)
    values.map do |value|
      # Entry represents a metric relation, e.g. 'metric_name': { '$gt': .9}
      [ I18n.t(key, scope: 'slos.metrics'), humanized_relation(key, value) ]
    end.join(' ')
  end
  
  # Convert a relation to a readable string
  #
  # A relation is a hash of the following structure:
  #
  #     { '<operator|qualifier>': '<value>', ... }
  #     { '<operator|qualifier>': [ '<value1>, <value2 ], ... }
  def humanized_relation(relation_name, relation_hash)
    main_relation_value = nil
    relation_hash.map do |key, value|
      if value.is_a?(Array) && value.size == 2
        value = value.join('..')
      end
      
      # if key is an operator, i.e., starts with `$`,
      if key.start_with?('$')
        # store value for the main relation for later pluralization of
        # added qualifiers
        # FIXME: this will not work if the main relation is not first in the hash
        main_relation_value ||= value
        # strip '$' from operator name and get translation for it
        [ I18n.t(key[1..-1], scope: 'slos.operators'), value.to_s ].join(' ')
      else
        # Entry represents qualifier, e.g., unit, interval, etc.
        qualifier_label = value # I18n.t(value, scope: 'slos.qualifiers')
        interval_qualifier = nil
        if key == 'interval'
          interval_qualifier = I18n.t('per', scope: 'slos.qualifiers')
        elsif main_relation_value != 1 && pluralizable?(qualifier_label)
          qualifier_label = ActiveSupport::Inflector.pluralize(qualifier_label)
        end
    
        [ interval_qualifier, qualifier_label, ].compact
      end
    end.join(' ')
  end
  
  def pluralizable?(qualifier_label)
    case qualifier_label
    # Don't pluralize currency symbols and 3-letter currency identifiers
    when '$', '€', /[A-Z]{3}/
      false
    else
      true
    end
  end
end
