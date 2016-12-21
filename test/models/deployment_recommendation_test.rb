require 'test_helper'

# NOTICE: Workloads are not considered here unless
# `@rails_app.update_constraints` is called explicitly
class DeploymentRecommendationTest < ActiveSupport::TestCase
  SEEDS_ROOT = Rails.root + 'db/seeds/'
  def load_seed(name)
    load ("#{SEEDS_ROOT}#{name}.rb")
  end

  setup do
    load_seed 'admin_user'
    load_seed 'ingredient_instance_rails_app_test'
    @rails_app = Ingredient.where(name: 'Rails Application with PostgreSQL Backend', is_template: false).first
  end

  test 'generate deployment recommendation' do
    create(:amazon_provider)

    @rails_app.construct_recommendations([200], perform_later: false)
    recommendation = @rails_app.deployment_recommendations.first

    expected_resources = %w(t2.micro t2.micro c3.2xlarge).collect { |n|  Resource.find_by_name(n) }
    ingredient_ids = @rails_app.children.sort_by(&:id).map(&:id).map(&:to_s)
    resource_codes = expected_resources.collect(&:resource_code)
    ingredients_hash = Hash[ingredient_ids.zip(resource_codes)]
    region_codes = expected_resources.collect(&:region_code)
    expected_recommendation =  {
      'ingredients' => ingredients_hash,
      'regions' => region_codes,
      'num_resources' => %w(10 10 1),
      'vm_cost' => '505.92',
      'total_cost' => 505941
    }
    # Example JSON:
    # { "ingredients": {"3":3159946989,"4":3159946989,"5":1207022094}
    #   "num_resources":["10","10","1"],
    #   "regions":[3005993341,3005993341,3005993341],
    #   "vm_cost":"505.92",
    #   "total_cost":505941
    # }
    assert_equal expected_recommendation, recommendation.more_attributes
  end

  test 'region constraint on root ingredient' do
    @rails_app.preferred_region_area_constraint = PreferredRegionAreaConstraint.create(preferred_region_area: 'US')
    azure_provider = create(:azure_provider)
    # Populate good and cheap resource in other region that should be favored without region constraint
    create(:resource, :azure_c0, region: 'North Europe', region_area: 'EU', provider: azure_provider)
    @rails_app.provider_constraint.preferred_providers = azure_provider.name

    @rails_app.construct_recommendations([200], perform_later: false)
    recommendation = @rails_app.deployment_recommendations.first

    expected_resources = %w(A0 A0 A0).collect { |n|  Resource.find_by_name(n) }
    region_codes = expected_resources.collect(&:region_code)
    assert_equal region_codes, recommendation.more_attributes['regions']
  end

  test 'hierarchical region constraint' do
    @rails_app.preferred_region_area_constraint = PreferredRegionAreaConstraint.create(preferred_region_area: 'US')
    @rails_app.preferred_region_area_constraint = PreferredRegionAreaConstraint.create(preferred_region_area: 'US')
    azure_provider = create(:azure_provider)
    # Populate good and cheap resource in other region that should be favored without region constraint
    create(:resource, :azure_c0, region: 'North Europe', region_area: 'EU', provider: azure_provider)
    @rails_app.provider_constraint.preferred_providers = azure_provider.name
    lb = Ingredient.find_by_name('NGINX')
    lb.preferred_region_area_constraint = PreferredRegionAreaConstraint.create(preferred_region_area: 'EU')
    create(:azure_provider)

    @rails_app.construct_recommendations([200], perform_later: false)
    recommendation = @rails_app.deployment_recommendations.first

    expected_resources = %w(A2 A3 Ax).collect { |n|  Resource.find_by_name(n) }
    region_codes = expected_resources.collect(&:region_code)
    assert_equal region_codes, recommendation.more_attributes['regions']
  end

  # NGINX ingredient does scale vertically
  test 'unsatisfiable constraint' do
    create(:amazon_provider)

    @rails_app.construct_recommendations([200_000], perform_later: false)
    recommendation = @rails_app.deployment_recommendations.first

    assert_equal DeploymentRecommendation::UNSATISFIABLE, recommendation.status
  end
end
