require File.dirname(__FILE__) + '/spec_helper'

describe "DemocracyInAction" do
  it "should respond to configure" do
    DemocracyInAction.should respond_to(:configure)
  end
  describe "configure" do
    it "should accept a block" do
      lambda { DemocracyInAction.configure { }}.should_not raise_error
    end
    it "should not require a block" do
      lambda { DemocracyInAction.configure }.should_not raise_error
    end
    it "the auth method should be exposed in the block" do
      lambda { DemocracyInAction.configure { auth } }.should_not raise_error
    end
    it "the mirror method should be exposed in the block" do
      lambda { DemocracyInAction.configure { mirror(:supporter, User) } }.should_not raise_error
    end
  end
end
