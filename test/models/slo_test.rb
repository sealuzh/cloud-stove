require 'test_helper'

class SloTest < ActiveSupport::TestCase
  test "does not save invalid slos" do
    invalid_json = "{invalid} JSON"
    slo = Slo.new(more_attributes: invalid_json)
    assert_not slo.valid?
    assert_equal [ :more_attributes ], slo.errors.keys
    # Until the record is saved, don't clobber invalid JSON so that can be
    # fixed in, e.g., a form field.
    assert_equal slo.more_attributes, invalid_json
  end
  
  test "saves acceptable slo" do
    assert Slo.create(more_attributes: { metric: 'answer', value: 42 })
    slo = Slo.new(more_attributes: '{"metric":"answer", "value": 42}')
    assert slo.valid?
  end
end
