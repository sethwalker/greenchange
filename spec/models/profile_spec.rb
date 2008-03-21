require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "Profile::Profile" do

  before do
    @user = User.new( :login => 'testo' , :password => 'test', :password_confirmation => 'test' )
    @profile = Profile.new(:friend => true, :entity => @user )
  end

  it "does not perform name validation for public profiles" do
    profile = Profile.new(:stranger => true, :entity => @user )
    profile.should have(0).errors_on(:first_name)
  end
  
  it "does not perform name validation for group profiles" do
    @group = Group.new( :name => 'testo' )
    profile = Profile.new(:friend => true, :entity => @group) 
    profile.should have(0).errors_on(:first_name)
  end
  
  it "validates the presence of first name" do
    @profile.should_not be_valid
    @profile.should have_at_least(1).errors_on(:first_name)
  end

  it "validates the presence of last name" do
    @profile.should_not be_valid
    @profile.should have_at_least(1).errors_on(:last_name)
  end

  it "validates first_name when built by the user" do
    profile = @user.build_private_profile :friend => true, :entity => @user 
    profile.should have_at_least(1).errors_on(:last_name)
  end
end

