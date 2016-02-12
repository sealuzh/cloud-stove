require 'test_helper'

class SloSetTest < ActiveSupport::TestCase
  test "does not save invalid slos" do
    invalid_json = "{invalid} JSON"
    slo_set = SloSet.new(more_attributes: invalid_json)
    assert_not slo_set.valid?
    assert_equal [ :more_attributes ], slo_set.errors.keys
    # Until the record is saved, don't clobber invalid JSON so that can be
    # fixed in, e.g., a form field.
    assert_equal slo_set.more_attributes, invalid_json
  end
  
  test "saves acceptable slo" do
    assert SloSet.create(more_attributes: { metric: 'answer', value: 42 })
    slo_set = SloSet.new(more_attributes: '{"metric":"answer", "value": 42}')
    assert slo_set.valid?
  end
end
