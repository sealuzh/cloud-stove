class CloudApplication < Base
  ma_accessor :body
  belongs_to :blueprint
  has_many :concrete_components, dependent: :destroy
  accepts_nested_attributes_for :concrete_components, allow_destroy: true
  
  def deep_dup
    deep_copy = self.dup
    deep_copy.concrete_components = self.concrete_components.map(&:deep_dup)
    deep_copy
  end
end
