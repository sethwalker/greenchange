require File.dirname(__FILE__) + '/../spec_helper'

describe Message do
  before do
    @sender = create_valid_user
    @recipient = create_valid_user
    @message = Message.create :sender => @sender, :recipient => @recipient, :body => "Hi", :sender_copy => false
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
      @messages = Message.spawn( @message.attributes.merge({ :recipients => "joey, frankie" }))
    end
    it "returns the # of messages matching the # of recipients" do
      @messages.size.should == 2
    end
  
  end
end
