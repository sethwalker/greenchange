require File.dirname(__FILE__) + '/../../spec_helper'

describe "Posts" do
  before do
  end

  describe "notifications" do
    before do
      @post = new_post
      @post.page.created_by = create_user
      @post.page.created_by.stub!(:receives_email_on).and_return(true)
    end
    it "should notify the author" do
      UserMailer.should_receive(:deliver_comment_posted)
      @post.save
    end
    it "should not notify the author if the author comments" do
      @post.user = @post.page.created_by
      UserMailer.should_not_receive(:deliver_comment_posted)
      @post.save
    end
  end
end
