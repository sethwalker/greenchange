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
      @user.should have_at_least(1).errors_on(:private_profile)
    end

    it "should not save a new profile if the profile is invalid" do
      lambda do
        @user.build_private_profile {}
        @user.save 
      end.should_not change(Profile, :count )
    end

    it "should have errors on profile unless the profile is valid" do
      profile = @user.build_private_profile :friend => true, :entity => @user
      profile.should_not be_valid
      profile.should have_at_least(1).errors_on(:first_name)
    end

    it "should have errors on user unless the profile is valid" do
      pending "profile validations"
      profile = @user.build_private_profile :friend => true, :entity => @user
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

describe User, "with preferences" do
  before do
    @user = create_valid_user
  end

  it "should accept arbitrary preference assignments" do
    @user.preferences.build :name => 'email', :value => '5'
    @user.preferences.size.should == 1
  end

  it "should accept named assignments" do
    @user.preferences = {'email' => '5' }
    @user.preferences.size.should == 1
  end

  it "should not allow fake keys" do
    pending "preference validation working"
    @user.preferences = {'fake preference' => '5' }
    @user.save.should be_false
  end

  it "should allow good keys" do
    @user.preferences = {'allow_info_sharing' => '5' }
    @user.save.should be_true
  end

  it "should return preference values by name" do
    @user.preferences = {'allow_info_sharing' => "0" }
    @user.preference_for( :allow_info_sharing ).should == "0"
  end

  it "should allow preferences to be updated" do
    @user.preferences.create :name => 'email_notification', :value => 'comments'
    @user.preferences = {'email_notification' => 'messages'}
    @user.save! && @user = User.find(@user)
    @user.preference_for( :email_notification ).should == "messages"
  end

  it "should not delete preferences" do
    @user.preferences.create :name => 'email_notification', :value => 'comments'
    @user.preferences.create :name => 'allow_info_sharing', :value => '1'
    @user.preferences = {'email_notification' => 'messages'}
    @user.save! && @user = User.find(@user)
    @user.preference_for( :allow_info_sharing ).should == '1'
  end

  describe "email preference" do
    it "should return false if none is the preference" do
      @user.preferences = {'email_notification' => 'none'}
      @user.receives_email_on('messages').should == false
      @user.receives_email_on('comments').should == false
    end
    it "should return true if comments is the preference" do
      @user.preferences = {'email_notification' => 'comments'}
      @user.receives_email_on('messages').should == true
      @user.receives_email_on('comments').should == true
    end
    it "should respect the preference if messages is the preference" do
      @user.preferences = {'email_notification' => 'messages'}
      @user.receives_email_on('messages').should == true
      @user.receives_email_on('comments').should == false
    end
  end
end

describe User, "with DIA saving" do
  before do
    class DemocracyInAction::API
      def self.disabled?; false; end
    end
    DemocracyInAction::API.stub!(:new).and_return(@api = stub('api', :process => 1234))
    @user = new_user
    @user.stub!(:private_profile).and_return(stub('profile', :democracy_in_action_proxies => stub('proxies', :find_by_remote_table => stub('proxy', :remote_key => 111))))
  end
  after do
    class DemocracyInAction::API
      def self.disabled?; true; end
    end
  end
  it "should save to DIA all members groups" do
    @api.should_receive('process').with('supporter_groups', {'supporter_KEY' => 111, 'groups_KEY' => Crabgrass::Config.dia_all_members_group_id}).and_return(2345)
    @user.add_to_democracy_in_action_groups
  end
  it "should save to DIA no groups group" do
    @api.should_receive('process').with('supporter_groups', {'supporter_KEY' => 111, 'groups_KEY' => Crabgrass::Config.dia_no_groups_group_id}).and_return(3456)
    @user.add_to_democracy_in_action_groups
  end
end

if !sphinx_running?
  puts "not running sphinx tests because no sphinx daemon running (start with 'rake ts:start RAILS_ENV=test')"
else

  User.destroy_all && `rake ts:index RAILS_ENV=test`

  describe User, "when searching with sphinx" do
    self.use_transactional_fixtures=false
    before(:all) do
      ThinkingSphinx.deltas_enabled = true
    end

    after(:all) do
      ThinkingSphinx.deltas_enabled = false
    end

    it "should find" do
      @user = create_user(:login => 'searchable')
      User.search('searchable').should include(@user)
    end

    it "should find searchable people" do
      @searchable = create_user(:login => 'searchable', :searchable => true)
      User.search('searchable', :with => {:searchable => 1}).should include(@searchable)
    end

    it "should not find unsearchable people" do
      @unsearchable = create_user(:login => 'searchable', :searchable => false)
      User.search('searchable', :with => {:searchable => 1}).should_not include(@unsearchable)
    end

    describe "when searching by name" do
      before do
        @user = create_user :private_profile => create_profile(:first_name => 'dweezil', :last_name => 'zappa')
      end

      it "should find people by first name" do
        User.search('dweezil').should include(@user)
      end

      it "should find people by last name" do
        User.search('zappa').should include(@user)
      end

      it "should find people by first and last name" do
        User.search('dweezil zappa').should include(@user)
      end
    end
  end
end
