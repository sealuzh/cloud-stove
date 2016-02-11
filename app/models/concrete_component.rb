class ConcreteComponent < Base
  ma_accessor :body
  belongs_to :component
  belongs_to :cloud_application
  has_many :slos
  accepts_nested_attributes_for :slos, allow_destroy: true


end
