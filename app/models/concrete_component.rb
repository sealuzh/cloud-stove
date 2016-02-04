class ConcreteComponent < Base
  ma_accessor :body
  belongs_to :component
  has_many :slos
  accepts_nested_attributes_for :slos

  def slos_attributes=(attributes)
    slos = []
    attributes.each do |key, value|
      slo = Slo.new(value) unless value['_destroy'] == '1'
      slo.more_attributes = ActiveSupport::JSON.decode(value['more_attributes'])
      slos << slo
    end
    self.slos = slos
    save!
  end

end
