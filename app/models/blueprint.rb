class Blueprint < Base
  ma_accessor :body
  has_many :components
  accepts_nested_attributes_for :components
end
