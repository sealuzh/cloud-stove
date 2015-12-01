class Base < ActiveRecord::Base
  self.abstract_class = true

  serialize :more_attributes, JSON
  after_initialize { |r| r.more_attributes ||= {} }
  alias_attribute :ma, :more_attributes
end
