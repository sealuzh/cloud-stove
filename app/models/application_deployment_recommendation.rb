class ApplicationDeploymentRecommendation < ActiveRecord::Base
  belongs_to :cloud_application
  has_many :deployment_recommendations

end
