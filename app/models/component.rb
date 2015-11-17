class Component < ActiveRecord::Base
  belongs_to :cloud_application
  serialize :cattributes, JSON
end
