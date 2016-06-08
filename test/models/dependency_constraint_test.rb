require 'test_helper'

class DependencyConstraintTest < ActiveSupport::TestCase
  test 'instantiation' do
    i1 = create(:ingredient)
    i2 = create(:ingredient)
    dc = create(:dependency_constraint, source: i1, target: i2)
    assert_equal i1, dc.source
    assert_equal i2, dc.target

    assert_equal dc, i1.constraints_as_source.first
    assert_equal dc, i2.constraints_as_target.first
  end
end
