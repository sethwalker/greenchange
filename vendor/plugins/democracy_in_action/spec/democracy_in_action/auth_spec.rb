require File.dirname(__FILE__) + '/../spec_helper'

describe "DemocracyInAction::Auth" do
  def act!
    DemocracyInAction.configure do |c|
      c.auth.username = 'user'
      c.auth.password = 'password'
      c.auth.org_key  = '1234'
    end
  end
  it "should set the username" do
    act!
    DemocracyInAction.auth.username.should == 'user'
  end
end
