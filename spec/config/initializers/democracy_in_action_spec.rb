require File.dirname(__FILE__) + '/../../spec_helper'

describe "DemocracyInAction initializer" do
  it "should load without error" do
    User.included_modules.should include(DemocracyInAction::Mirroring::ActiveRecord)
  end
end
