class ConcreteComponent < Base
  ma_accessor :body
  belongs_to :component
end
