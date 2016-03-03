require 'test_helper'

class CloudApplicationTest < ActiveSupport::TestCase
  test "should create new app instance from blueprint" do
    blueprint = blueprints(:multitier_app)
    cloud_application = CloudApplication.new_from_blueprint(blueprint)
    assert_kind_of CloudApplication, cloud_application

    assert_equal blueprint.name, cloud_application.name
    assert_equal blueprint.body, cloud_application.body
    assert_equal blueprint.components.map(&:name), cloud_application.concrete_components.map(&:name)
    cloud_application.concrete_components.each do |concrete_component|
      assert_not_nil concrete_component.component
      assert_includes blueprint.components.to_a, concrete_component.component
    end
  end
end
