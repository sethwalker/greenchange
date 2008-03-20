require File.dirname(__FILE__) + '/../spec_helper'

describe User do

  before do
    @user = create_valid_user
  end

  describe "when forgetting a password" do

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

  describe "when saving with a profile" do
    before do
      @user = User.new
    end

    it "checks to be sure there's an email" do
      @user.should have_at_least(1).errors_on(:email) 
    end

    it "sends an error if the email has the wrong format" do
      @user.email = "cheese"
      @user.should have_at_least(1).errors_on(:email) 
    end

    it "accepts valid emails" do
      @user.email = "pablo@laminated.com"
      @user.should have(0).errors_on(:email) 
    end

    it "requires a profile" do
      pending "profile validations"
      @user.should have_at_least(1).errors_on(:profiles)
    end

    it "should not save a new profile if the profile is invalid" do
      lambda do
        @user.profiles.build {}
        @user.save 
      end.should_not change(Profile, :count )
    end

    it "should have errors on profile unless the profile is valid" do
      profile = @user.profiles.build :friend => true, :entity => @user
      profile.should_not be_valid
      profile.should have_at_least(1).errors_on(:first_name)
    end

    it "should have errors on user unless the profile is valid" do
      pending "profile validations"
      profile = @user.profiles.build :friend => true, :entity => @user
      @user.should_not be_valid
      @user.should have_at_least(1).errors_on(:profiles)
    end

  end

  describe User, "profile actions" do
    before do
      @person = create_valid_user
    end

    it "should show the public profile to any user" do
      @user.profile_for( @person ).should == @user.public_profile
    end

    it "should show the private profile to contacts" do
      @user.contacts << @person
      @user.profile_for( @person ).should == @user.private_profile
    end
  end

end

describe User, "with issues" do
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

describe User, "with privileges" do
  before do
    @user = create_valid_user
  end

  it "should have a set of privileged access collection ids" do
    @user.restricted_collection_ids.should_not be_empty
  end
  
end
describe User, "with bookmarks" do
  it "should respond to bookmarked?" do
    User.new.should respond_to(:bookmarked?)
  end
  it "bookmarked? should return nil if not bookmarked" do
    u = create_valid_user
    p = create_valid_page
    u.bookmarked?(p).should be_nil
  end

  it "bookmarked? should not be false if a page is bookmarked" do
    u = create_valid_user
    p = create_valid_page
    u.bookmarked_pages << p
    u.bookmarked?(p).should_not be_false
  end
  it "bookmark! should add a page to bookmarked_pages" do
    u = create_valid_user
    p = create_valid_page
    u.bookmark!(p)
    u.bookmarked?(p).should_not be_false
  end

  it "should respond to bookmarked_pages" do
    u = User.new
    u.should respond_to(:bookmarked_pages)
  end
end

describe User, "in a namespace" do

  before do
    @user = create_valid_user :login => 'evil_scientist'
    @group = create_valid_group:name => 'robot_army'
  end

  it "does not allow users with the same name as groups" do
    lambda { user2 = create_valid_user :login => 'robot_army' }.should raise_error
  end

end
