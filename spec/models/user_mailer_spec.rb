require File.dirname(__FILE__) + '/../spec_helper'

describe UserMailer do
  before do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  describe "message received" do
    it "should render both parts" do
      @message = Message.new :recipient => new_user
      UserMailer.deliver_message_received(@message)
      ActionMailer::Base.deliveries.first.parts.length.should == 2 
    end
  end

  describe "invitation received" do
    it "should render both parts" do
      @message = Invitation.new :recipient => new_user
      UserMailer.deliver_invitation_received(@message)
      ActionMailer::Base.deliveries.first.parts.length.should == 2 
    end
  end

  describe "comment posted" do
    it "should render both parts" do
      @message = Invitation.new :recipient => new_user
      @post = new_post(:discussion => new_discussion(:page => new_page(:created_by => new_user)))
      UserMailer.deliver_comment_posted(@post)
      ActionMailer::Base.deliveries.first.parts.length.should == 2 
    end
  end
end
