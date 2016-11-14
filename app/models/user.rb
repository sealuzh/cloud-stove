class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable

  include DeviseTokenAuth::Concerns::User

  has_many :ingredients
  has_many :deployment_recommendations

  has_many :constraints
  has_many :cpu_constraints
  has_many :ram_constraints
  has_many :dependency_constraints
  has_many :preferred_region_area_constraints
  has_many :provider_constraints
  has_many :scaling_constraints

  has_many :cpu_workloads
  has_many :ram_workloads
  has_many :user_workloads
  has_many :traffic_workloads
  has_many :scaling_workloads

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  scope :admin, -> { where(is_admin: true) }

  after_create :seed_user

  def self.stove_admin
    self.admin.first
  end

  private

    def seed_user
      unless Rails.env.test? || self.is_admin
        # Use application from first admin user as seed for new users
        admin = User.admin.first
        app = (admin.ingredients.select { |i| i.application_root? && !i.is_template }).first
        app_copy = app.copy
        app_copy.assign_user!(self)
        app.deployment_recommendations.each do |recommendation|
          app_copy.deployment_recommendations << DeploymentRecommendation.create(
            status: recommendation.status,
            num_simultaneous_users: recommendation.num_simultaneous_users,
            more_attributes: remap_more_attributes(recommendation.more_attributes, app_copy),
            user: self
          )
        end
      end
    end

    def remap_more_attributes(more_attributes, ingredient)
      new_more_attributes = more_attributes
      new_leaf_ids = ingredient.all_leafs.sort_by(&:id).map(&:id)
      new_mappings = {}
      if more_attributes['ingredients'].present?
        more_attributes['ingredients'].values.each_with_index do |resource, index|
          new_id = new_leaf_ids[index]
          new_mappings[new_id] = resource
        end
        new_more_attributes['ingredients'] = new_mappings
        new_more_attributes
      else
        more_attributes
      end
    end
end
