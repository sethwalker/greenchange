require File.dirname(__FILE__) + '/../spec_helper'

describe "An unauthenticated user" do

  before do
    @user = UnauthenticatedUser.new

    @public_page = Page.new(:public => true)
    @private_page = Page.new(:public => false)
  end

  it "should be allowed to view (or read) public pages" do
    @user.should be_allowed_to(:view, @public_page)
    @user.should be_allowed_to(:read, @public_page)
  end

  it "should not be allowed to view (or read) private pages" do
    @user.should_not be_allowed_to(:view, @private_page)
    @user.should_not be_allowed_to(:read, @private_page)
  end

  it "should not raise PermissionDenied for missing 'may_xxx?' methods" do
    @user.may_mangle?(@public_page).should_not raise_error(PermissionDenied)
  end

  it "should return false for missing 'may_xxx?' methods" do
    @user.may_mangle?(@public_page).should be_false
  end

  it "should raise PermissionDenied for missing 'may_xxx!' methods" do
    lambda { @user.may_doodoo_mangle! @public_page }.should raise_error(PermissionDenied)
  end

  it "should raise NoMethodError for missing methods that are not related to permissions" do
    lambda { @user.an_unimplemented_method }.should_not raise_error(PermissionDenied)
    lambda { @user.an_unimplemented_method }.should raise_error(NoMethodError)
  end
end
