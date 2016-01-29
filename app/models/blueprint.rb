class Blueprint < Base
  ma_accessor :body
  has_many :components
  has_many :cloud_applications
  accepts_nested_attributes_for :components
end
