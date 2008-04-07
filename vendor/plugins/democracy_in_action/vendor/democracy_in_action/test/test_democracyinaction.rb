require File.dirname(__FILE__) + '/test_helper.rb'

class TestDemocracyinaction < Test::Unit::TestCase

  def setup
  end
  
  def test_legacy
    assert_equal DIA_API_Simple.superclass, DemocracyInAction::API
    DIA_API.expects(:warn)
    assert DIA_API.create.is_a?(DemocracyInAction::API)
  end
end
