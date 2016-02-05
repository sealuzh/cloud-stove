class Component < Base
  ma_accessor :body
  belongs_to :blueprint
  has_many :concrete_components
  has_one :deployment_rule
  accepts_nested_attributes_for :deployment_rule

end
