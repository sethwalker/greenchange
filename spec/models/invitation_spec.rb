require File.dirname(__FILE__) + '/../spec_helper'

describe Invitation do

  describe "when spawning" do
    it "should produce invitation objects" do
      @invites = Invitation.spawn :recipients => 'harry, jane', :body => 'helloze', :sender => create_valid_user
      @invites.all? { |inv| inv.is_a? Invitation }.should be_true
    end
  end
end
