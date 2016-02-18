class Component < Base
  ma_accessor :body
  belongs_to :blueprint
  has_many :concrete_components
  has_one :deployment_rule
  accepts_nested_attributes_for :deployment_rule

  def deep_dup
    deep_copy = self.dup
    deep_copy.deployment_rule = self.deployment_rule.deep_dup
    deep_copy
  end
end
