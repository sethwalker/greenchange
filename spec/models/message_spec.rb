require File.dirname(__FILE__) + '/../spec_helper'

describe Message do
  before do
    @sender = create_valid_user
    @recipient = create_valid_user
    @message = Message.create :sender => @sender, :recipient => @recipient, :subject => 'Dude!', :body => "Hi", :sender_copy => false
  end

  describe "to finder" do
    it "finds messages to the given user" do
      Message.to(@recipient).should include(@message)
    end
    it "does not find messages to other users" do
      Message.to(@sender).should_not include(@message)
    end
  end

  describe "from finder" do
    it "finds messages from the given user" do
      Message.from(@sender).should include(@message)
    end
    it "does not find messages from other users" do
      Message.from(@recipient).should_not include(@message)
    end
  end

  describe "permissions for messages" do
    it "allow nothing unless the user sent or is receiving the message" do
      other_user = create_valid_user
      other_user.should_not be_allowed_to(:view, @message)
    end

    it "allows recipients to reply to their message" do
      @recipient.should be_allowed_to(:reply, @message)
    end
  
    it "does not allow the sender to view the sent message" do
      @sender.should_not be_allowed_to(:view, @message)
    end
  end

  describe "when spawning for multiple recipients" do
    before do
      @message = Message.create :sender => @sender, :subject => 'Dude!', :body => "Hi", :sender_copy => false
      @recipients = "joey, frankie"
      User.stub!(:find_by_login).and_return(create_valid_user(:login => 'joey'))
    end
    def act!
      @messages = Message.spawn( @message.attributes.merge({ :recipients => @recipients }))
    end
    it "returns the # of messages matching the # of recipients" do
      act!
      @messages.size.should == 2
    end
    it "can deal with more than 2 recipients" do
      @recipients = "joey, frankie, marie"
      act!
      @messages.size.should == 3
    end
    it "should return messages" do
      act!
      @messages.first.should be_an_instance_of(Message)
    end
    it "should return messages for each recipient" do
      act!
      @messages.each {|m| m.should be_an_instance_of(Message)}
    end
    it "should return a message with the recipient matching the login" do
      User.should_receive(:find_by_login).with('frankie').and_return(create_valid_user(:login => 'frankie'))
      User.should_receive(:find_by_login).with('joey').and_return(create_valid_user(:login => 'joey'))
      act!
      @messages.first.recipient.login.should == "joey"
    end
    it "all messages should have the subject of the original message" do
      act!
      @messages.each {|m| m.subject.should == @message.subject}
    end
    it "all messages should have the body of the original message" do
      act!
      @messages.each {|m| m.body.should == @message.body}
    end
    it "accepts space delimited strings" do
      @recipients = "joey frankie"
      act!
      @messages.size.should == 2
    end

    it "returns an invalid message if there r no recipients" do
      messages = Message.spawn( {}  )
      messages.first.should_not be_valid
    end
    it "passes all existing params to a single message if there r no recipients" do
      messages = Message.spawn( { :body => 'joe' }  )
      messages.first.body.should == 'joe'
    end
    
    it "returns an invalid message if recipients/logins do not exist" do
      User.stub!(:find_by_login).and_return(nil)
      act!
      @messages.first.should_not be_valid
    end

    it "accepts an array of User logins" do
      @recipients = [ "joey", "frankie" ]
      act!
      @messages.size.should == 2
    end
    it "should save messages to db" do
      @recipients = [ "joey", "frankie" ]
      lambda { act! }.should change(Message, :count).by(2)
    end

  end
end

describe Message, "with email notification" do
  before do
    @recipient = create_user
    @sender = create_user
    @message = Message.new :sender => @sender, :recipient => @recipient, :subject => 'Dude!', :body => "Hi", :sender_copy => false
  end
  it "should notify recipients if they allow it" do
    @recipient.should_receive(:receives_email_on).and_return(true)
    UserMailer.should_receive(:deliver_message_received).with(@message)
    @message.save
  end

  it "should not notify recipients if they don't allow it" do
    @recipient.should_receive(:receives_email_on).and_return(false)
    UserMailer.should_not_receive(:deliver_message_received)
    @message.save
  end
end
