class Blueprint < Base
  ma_accessor :body
  has_many :components, dependent: :destroy
  has_many :cloud_applications
  accepts_nested_attributes_for :components, allow_destroy: true
end
