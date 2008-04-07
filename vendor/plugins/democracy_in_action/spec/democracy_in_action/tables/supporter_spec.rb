require File.dirname(__FILE__) + '/../../spec_helper'

describe "DemocracyInAction::Tables::Supporter" do
  before do
    @supporter = DemocracyInAction::Tables::Supporter.new
  end
  it "should respond have supporter columns" do
    @supporter.columns.should include('First_Name')
  end
  it "should not be affected by other Tables:: instances" do
    group = DemocracyInAction::Tables::Groups.new
    supporter = DemocracyInAction::Tables::Supporter.new
    event = DemocracyInAction::Tables::Event.new
    supporter.columns.should include('First_Name')
  end
  it "should not include Password in columns" do
    @supporter.columns.should_not include('Password')
  end
end
