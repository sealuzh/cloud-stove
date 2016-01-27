class ConcreteComponent < ActiveRecord::Base
  ma_accessor :body
  belongs_to :component
end
