require 'test_helper'

class SloTest < ActiveSupport::TestCase
  test "does not save invalid slos" do
    slo = Slo.new(more_attributes: "{invalid} JSON")
    assert_not slo.valid?
    assert_equal [ :more_attributes ], slo.errors.keys
  end
  
  test "saves acceptable slo" do
    assert Slo.create(more_attributes: { metric: 'answer', value: 42 })
    slo = Slo.new(more_attributes: '{"metric":"answer", "value": 42}')
    assert slo.valid?
  end
end
