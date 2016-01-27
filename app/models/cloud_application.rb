class CloudApplication < Base
  ma_accessor :body
  belongs_to :blueprint
  has_many :concrete_components
end
