require File.dirname(__FILE__) + '/../spec_helper'

describe Invitation do
  before do
    #@invite = Invitation.new
    @invite = Invitation.create :sender => (@sender = create_valid_user ), :recipient => (@recipient = create_valid_user ), :group => ( @group = create_valid_group )
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

  describe "when accepted" do
    before do
      @invite = Invitation.create :sender => (@sender = create_valid_user ), :recipient => (@recipient = create_valid_user ), :group => ( @group = create_valid_group )
    end
    it "creates rsvps" do
      event_page = Tool::Event.create :title => 'none'
      event = event_page.build_data :is_all_day => true, :page => event_page
      event.save! 
      @invite.event = event
      @invite.accept!
      @recipient.rsvps.find(:first, :conditions =>  [ 'event_id = ?', event ]).should_not be_nil
    end

    it "creates memberships" do
      @invite.accept!
      @group.membership_for(@recipient).should_not be_nil
    end

    it "creates contacts" do
      @invite.contact = @sender
      @invite.accept!
      @recipient.contact_for(@sender).should_not be_nil
    end

    it "does not duplicate existing relationships" do
      invite_hash = { :sender => (@sender = create_valid_user ), :recipient => (@recipient = create_valid_user ), :group => ( @group = create_valid_group ) }
      @invite = Invitation.create invite_hash
      Membership.create :user => @recipient, :group => @group
      lambda { @invite.accept! }.should_not change( Membership, :count )
    end
  end

  describe "validations" do
    it "checks prior existence of a membership for group invitations" do

      invite_hash = { :sender => (@sender = create_valid_user ), :recipient => (@recipient = create_valid_user ), :group => ( @group = create_valid_group ) }
      Membership.create :user => @recipient, :group => @group
      @invite = Invitation.create invite_hash
      @invite.should_not be_valid
      #lambda { @invite.accept! }.should_not change( Membership, :count )
      
    end
  end
end
