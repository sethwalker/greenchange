require File.dirname(__FILE__) + '/../spec_helper'

describe User, "when forgetting a password" do

  before do
    @user = create_valid_user
  end

  it "should find a user by email address" do
    User.find_for_forget("aviary@birdcage.com").should be_an_instance_of(User)
  end

  it "should create a password reset code" do
    @user.__send__ :make_password_reset_code
    @user.password_reset_code.should_not be_nil
  end

  it "should be have a general forgot password method" do
    @user.forgot_password
    @user.recently_forgot_password?.should be_true 
  end

  it "should allow resetting the password" do
    @user.forgot_password
    @user.save!
    user = User.find @user.id
    user.reset_password
    user.password_reset_code.should be_blank
  end

end

describe User do
  it "should have issues" do
    User.new.should respond_to(:issues)
  end

  it "should be able to add an issue" do
    i = Issue.find_or_create_by_name('an issue')
    u = create_valid_user
    u.issues << i
    u.issues.should include(i)
  end

  it "should be able to set issues" do
    i = Issue.find_or_create_by_name('an issue')
    u = create_valid_user
    u.issue_ids = [i.id]
    u.issues.should include(i)
  end
end
