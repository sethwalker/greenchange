require File.dirname(__FILE__) + '/../spec_helper'

describe NetworkInvitation do

  before do
    @invite = NetworkInvitation.new
  end

  describe "attribute assignment" do
    it "accepts attributes on create" do
      invite = NetworkInvitation.new( :sender => 'boze' )
      invite.sender.should == 'boze'
    end
    
    it "accepts hash assignment" do
      @invite.attributes = ({ :sender => 'betsy' } )
      @invite.sender.should == 'betsy'
    end

    it "accepts attributes" do
      @invite.sender = "bob"
      @invite.sender.should == 'bob'
    end

    it "accepts a recipient_email" do
      @invite.recipient_email = "cheese@cheese.com"
      @invite.recipient_email.should == "cheese@cheese.com"
    end

    it "converts a recipient email to a Recipient object" do
      @invite.recipient_email = "cheese@cheese.com"
      @invite.recipient.should be_an_instance_of(EmailRecipient)
    end

  end

  describe "validation" do
    it "is not valid without a recipient" do
    #  lambda{ @invite.validate }.should raise_error( NetworkInvitation::NoRecipientGiven )
      @invite.valid?
      @invite.should have_at_least(1).errors_on(:recipient)
    end

    it "can state the problem with the recipient" do
      @invite.valid?
      @invite.errors_on(:recipient).should match(/is blank/)
    end

    it "is not valid if the email address is not valid" do
      @invite.recipient = EmailRecipient.new :email => 'cheese'
      @invite.valid?
      @invite.errors_on(:recipient).should match(/not valid/)
    end

    it "is not valid if the email recipient has requested blocking" do
      @invite.recipient = EmailRecipient.new :email => 'cheese@cheese.com', :status => 'blocked'
      @invite.valid?
      @invite.errors_on(:recipient).should match(/no further email/)
      
    end
    it "is valid if the email is valid" do
      @invite.recipient_email = "cheese@cheese.com"
      @invite.should be_valid
    end

    it "is not valid if the recipient is already a member" do
      create_user :email => 'jo@jo.com'
      @invite.recipient = EmailRecipient.new :email => 'jo@jo.com'
      @invite.valid?
      @invite.errors_on(:recipient).should match(/an existing member/)
    end

  end

  describe "spawing invitations" do
    before do
      @stubbed_invite = NetworkInvitation.new
      @stubbed_invite.stub!(:send_email)
      NetworkInvitation.stub!(:new).and_return(@stubbed_invite)
    end

    it "should send an email for each valid email it is passed" do
      message_params = { :recipients => 'cheese@cheese.com, rats@rats.com, celery@pbj.com', :body => 'hize' }
      @stubbed_invite.stub!(:valid?).and_return( true )
      @stubbed_invite.should_receive(:send_email).exactly(3).times
      NetworkInvitation.spawn message_params
    end

    it "should not send email for invalid emails" do
      message_params = { :recipients => 'cheesecom, rats@rats.com, celery@pbj.com', :body => 'hize', :sender => create_user }
      @stubbed_invite.should_receive(:valid?).and_return( true,true,false)
      @stubbed_invite.should_receive(:send_email).exactly(2).times
      NetworkInvitation.spawn message_params
    end
  end

  describe "sending email" do
    it "should create emails" do
      @invite.attributes = { :sender => create_user, :recipient_email => 'cheese@cheese.com' }
      @invite.send_email.should be_an_instance_of(TMail::Mail)
    end
    it "should not send emails for invalid addresses" do
      @invite.attributes = { :sender => create_user, :recipient_email => 'cheese.com' }
      @invite.send_email.should be_nil
    end
  end
end
