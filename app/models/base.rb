class Base < ActiveRecord::Base
  self.abstract_class = true

  serialize :more_attributes, JSON
  after_initialize { |r| r.more_attributes ||= {} }
  alias_attribute :ma, :more_attributes
  
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
