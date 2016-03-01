class Base < ActiveRecord::Base
  self.abstract_class = true

  serialize :more_attributes, JSON
  after_initialize do |r|
    if has_attribute?(:more_attributes)
      r.more_attributes ||= {}
      serialize_more_attributes(r) rescue true
    end
  end
  alias_attribute :ma, :more_attributes

  validates_each :more_attributes do |record, attr, value|
    begin
      ActiveSupport::JSON.decode(value) unless value.is_a?(Hash)
    rescue ActiveSupport::JSON.parse_error => e
      record.errors.add(attr, 'must be a valid JSON Hash')
    end
  end
  
  before_save :serialize_more_attributes

  private
  def serialize_more_attributes(record = self)
    if record.more_attributes && !record.more_attributes.is_a?(Hash)
      record.more_attributes = ActiveSupport::JSON.decode(record.more_attributes)
    end
  end
  
  class << self
    # Adapted from activesupport/lib/active_support/core_ext/module/attribute_accessors.rb
    def ma_accessor(*syms)
      ma_reader(*syms)
      ma_writer(*syms)
    end
  
    def ma_reader(*syms)
      options = syms.extract_options!
      syms.each do |sym|
        class_eval("
          def #{sym}
            more_attributes['#{sym}']
          end
  ", __FILE__, __LINE__ + 1)
      end
    end

    def ma_writer(*syms)
      options = syms.extract_options!
      syms.each do |sym|
        class_eval("
          def #{sym}=(obj)
            more_attributes['#{sym}'] = obj
          end
  ", __FILE__, __LINE__ + 1)
      end
    end
  end
end
