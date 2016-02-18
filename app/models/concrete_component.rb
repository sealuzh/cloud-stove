class ConcreteComponent < Base
  ma_accessor :body
  belongs_to :component
  belongs_to :cloud_application
  has_many :slo_sets
  accepts_nested_attributes_for :slo_sets, allow_destroy: true

  def deep_dup
    deep_copy = self.dup
    deep_copy.slo_sets = self.slo_sets.map(&:deep_dup)
    deep_copy
  end
end
