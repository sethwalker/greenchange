require File.dirname(__FILE__) + '/../spec_helper'

describe UserMailer do

  describe "message received" do
    it "should render both parts" do
      @message = create_message :recipient => create_user, :sender => create_user
      mail = UserMailer.create_message_received(@message)
      mail.parts.length.should == 2
    end
  end

  describe "contact request received" do
    it "should render both parts" do
      @message = create_invitation :recipient => create_user, :sender => (sender = create_user), :invitable => sender
      mail = UserMailer.create_contact_request_received(@message)
      mail.parts.length.should == 2 
    end
  end

  describe "invitation received" do
    it "should render both parts" do
      @message = create_invitation :recipient => create_user, :sender => create_user, :invitable => create_group
      mail = UserMailer.create_invitation_received(@message)
      mail.parts.length.should == 2 
    end
  end

  describe "comment posted" do
    before do
      @post = create_post
      @post.discussion.page.created_by = create_user :email => "deepthought@example.com"
    end

    it "should render both parts" do
      mail = UserMailer.create_comment_posted(@post)
      mail.parts.length.should == 2 
    end

    it "should be from the comment poster" do
      @post.user.private_profile.attributes = {:first_name => "happy", :last_name => "hoppy"}
      mail = UserMailer.create_comment_posted(@post)
      mail.subject.should match(/#{@post.user.display_name} left you a comment/)
    end

    it "should be to the page creator" do
      mail = UserMailer.create_comment_posted(@post)
      mail.to.should include(@post.discussion.page.created_by.email)
    end
  end
end
