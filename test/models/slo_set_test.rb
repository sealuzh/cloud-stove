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
  
  test 'converts SLOs to readable form' do
    slo = SloSet.new
    [
      [
        [ 'availability > 0.95', { 'availability': { '$gt': 0.95 } } ],
        [ 'response time ≤ 2 seconds', { 'response_time': { '$lte': 2, 'unit': 'second' } } ],
      ],
      [
        [ 'costs ≤ 200 $ per month', { 'costs': { '$lte': 200, 'unit': '$', interval: 'month' } } ],
        [ 'availability < 0.95', { 'availability': { '$lt': 0.95 } } ],
      ],
      [
        [ 'availability = 0.95', { 'availability': { '$eq': 0.95 } } ],
        [ 'costs ≤ 200 € per month', { 'costs': { '$lte': 200, 'unit': '€', interval: 'month' } } ],
      ],
      [
        [ 'costs ≤ 200 EUR per day', { 'costs': { '$lte': 200, 'unit': 'EUR', interval: 'day' } } ],
        [ 'response time ≤ 2 minutes', { 'response_time': { '$lte': 2, 'unit': 'minute' } } ],
      ]
    ].each do |slo_attrs|
      expected, slo_relations = slo_attrs.pop.zip(*slo_attrs)
      slo.ma = slo_relations.inject({}) { |res, obj| res.merge!(obj) }
      assert_equal expected, slo.humanize
    end
  end
end
