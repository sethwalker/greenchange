require File.dirname(__FILE__) + '/../spec_helper'

describe Invitation do
  before do
    #@invite = Invitation.new
    @invite = Invitation.create :sender => (@sender = create_user ), :recipient => (@recipient = create_user ), :group => ( @group = create_group )
  end

  describe "when spawning" do
    it "should produce invitation objects" do
      @invites = Invitation.spawn :recipients => 'harry, jane', :body => 'helloze', :sender => create_user
      @invites.all? { |inv| inv.is_a? Invitation }.should be_true
    end
  end

  describe "to be contacts" do
    it "knows its nature" do
      @invite.contact = create_user
      @invite.should be_contact
    end
    it "accepts assignments" do
      @invite.contact = create_user
      @invite.contact.should be_an_instance_of(User)
    end
  end

  describe "when accepted" do
    before do
      @invite = Invitation.create :sender => (@sender = create_user ), :recipient => (@recipient = create_user ), :group => ( @group = create_group )
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
      invite_hash = { :sender => (@sender = create_user ), :recipient => (@recipient = create_user ), :group => ( @group = create_group ) }
      @invite = Invitation.create invite_hash
      Membership.create :user => @recipient, :group => @group
      lambda { @invite.accept! }.should_not change( Membership, :count )
    end
  end

  describe "validations" do
    it "checks prior existence of a membership for group invitations" do

      invite_hash = { :sender => (@sender = create_user ), :recipient => (@recipient = create_user ), :group => ( @group = create_group ) }
      Membership.create :user => @recipient, :group => @group
      @invite = Invitation.create invite_hash
      @invite.should_not be_valid
      #lambda { @invite.accept! }.should_not change( Membership, :count )
      
    end
  end
end

describe Message, "with email notification" do
  before do
    @recipient = create_user
    @sender = create_user
    @message = Invitation.new :sender => @sender, :recipient => @recipient, :subject => 'Dude!', :body => "Hi", :sender_copy => false, :group => create_group
  end
  it "should notify recipients if they allow it" do
    @recipient.should_receive(:receives_email_on).and_return(true)
    UserMailer.should_receive(:deliver_invitation_received).with(@message)
    @message.save!
  end

  it "should not notify recipients if they don't allow it" do
    @recipient.should_receive(:receives_email_on).and_return(false)
    UserMailer.should_not_receive(:deliver_invitation_received)
    @message.save!
  end

  it "should not blow up on Errno::ECONNRESET" do
    invitation = new_invitation
    invitation.stub!(:contact?).and_return(false)
    invitation.stub!(:recipient).and_return(stub('recipient', :receives_email_on => true))
    UserMailer.should_receive(:deliver_invitation_received).and_raise(Errno::ECONNRESET)
    lambda { invitation.notify_recipient }.should_not raise_error
  end
end
