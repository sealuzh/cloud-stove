class User < ActiveRecord::Base

  has_many :ingredients
  has_many :deployment_recommendations

  has_many :constraints
  has_many :cpu_constraints
  has_many :ram_constraints
  has_many :dependency_constraints
  has_many :preferred_region_area_constraints

  has_many :cpu_workloads
  has_many :ram_workloads
  has_many :user_workloads
  has_many :traffic_workloads

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
