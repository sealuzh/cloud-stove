class Base < ActiveRecord::Base
  self.abstract_class = true
  
  serialize :more_attributes, JSON
end