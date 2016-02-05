class CloudApplication < Base
  ma_accessor :body
  belongs_to :blueprint
  has_many :concrete_components
  accepts_nested_attributes_for :concrete_components, allow_destroy: true
end
