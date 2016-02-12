class DeploymentRecommendation < ActiveRecord::Base
  has_and_belongs_to_many :resources
  belongs_to :slo_set
end
