class ConcreteComponent < Base
  ma_accessor :body
  belongs_to :component
  has_many :slos
  accepts_nested_attributes_for :slos, allow_destroy: true


end
