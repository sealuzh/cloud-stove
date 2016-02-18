class Blueprint < Base
  ma_accessor :body
  has_many :components, dependent: :destroy
  has_many :cloud_applications
  accepts_nested_attributes_for :components, allow_destroy: true
  
  def deep_dup
    deep_copy = self.dup
    deep_copy.components = self.components.map(&:deep_dup)
    deep_copy
  end
end
