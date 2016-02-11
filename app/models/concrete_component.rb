class ConcreteComponent < Base
  ma_accessor :body
  belongs_to :component
  belongs_to :cloud_application
  has_many :slo_sets
  accepts_nested_attributes_for :slo_sets, allow_destroy: true


end
