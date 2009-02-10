require File.dirname(__FILE__) + '/../spec_helper'

describe PasswordsController do
  describe "when user has invalid subscriptions" do
    before do
      @user = create_user
      @sub = new_subscription(:user => @user, :url => 'http://example.com')
      @sub.stub!(:update!).and_return(true)
      @sub.stub!(:discover_feed_url).and_return(false)
      @sub.save(false)
      @sub.errors.add :url, "not valid"
      @user.subscriptions << @sub
      User.stub!(:find_for_forget).and_return @user
      User.stub!(:find_by_password_reset_code).and_return @user
    end

    it "delivers forgot password mail" do
      UserMailer.should_receive(:deliver_forgot_password)
      post :create, :email => 'test@example.com'
    end

    it "allows you to request a password reset" do
      lambda { post :create, :email => 'test@example.com' }.should_not raise_error
    end
     
    it "delivers reset password mail" do
      UserMailer.should_receive(:deliver_reset_password)
      post :update, :id => 'reset code hash', :password => 'password', :password_confirmation => 'password'
    end

    it "allows you to update your password" do
      lambda { post :update, :id => 'reset code hash', :password => 'password', :password_confirmation => 'password' }.should_not raise_error
    end
  end
end
