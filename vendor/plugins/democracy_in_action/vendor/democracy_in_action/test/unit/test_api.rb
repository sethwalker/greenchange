require File.dirname(__FILE__) + '/../test_helper'

class ApiTest < Test::Unit::TestCase
  def setup
    @api = DemocracyInAction::API.new('authCodes' => [@@USER, @@PASS, @@ORG])
    Net::HTTPSuccess.stubs(:===).returns(true) unless connect?
  end

  def test_get
    unless connect?
      response = stub(:body => File.read(File.dirname(__FILE__) + '/../fixtures/supporter_by_limit_1.xml'), :get_fields => false)
      Net::HTTP.any_instance.stubs(:request).returns(response)
    end
    result = @api.get('supporter', :limit => 1).first
    assert_match /^\d+$/, result['key']
    assert_not_nil result['Email']
  end

  def test_process
    unless connect?
      response = stub(:body => File.read(File.dirname(__FILE__) + '/../fixtures/process.xml'), :get_fields => false)
      Net::HTTP.any_instance.stubs(:request).returns(response)
    end
    result = @api.process 'supporter', :Email => 'test3@radicaldesigns.org'
    assert_match /^\d+$/, result
  end
end
