require File.dirname(__FILE__) + '/../spec_helper'

describe Invitation do
  before do
    @invite = Invitation.new
  end

  describe "when spawning" do
    it "should produce invitation objects" do
      @invites = Invitation.spawn :recipients => 'harry, jane', :body => 'helloze', :sender => create_valid_user
      @invites.all? { |inv| inv.is_a? Invitation }.should be_true
    end
  end

  describe "to be contacts" do
    it "knows its nature" do
      @invite.contact = create_valid_user
      @invite.should be_contact
    end
    it "accepts assignments" do
      @invite.contact = create_valid_user
      @invite.contact.should be_an_instance_of(User)
    end
  end
end
