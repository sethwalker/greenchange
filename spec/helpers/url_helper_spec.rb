require File.dirname(__FILE__) + '/../spec_helper'

describe UrlHelper do
  before do
    @user = create_valid_user :login => 'linkedout'
    @group = create_valid_group :name => 'linked'
  end

  it "should generate name based URLs for groups" do
    url = url_for_group(@group)
    url.should == '/groups/show/linked'

    url = url_for_group(@group, :action => 'link')
    url.should == '/groups/link/linked'
  end

  it "should generate name based URLs for users" do
    url = url_for_user(@user)
    url.should == '/people/show/linkedout'

    url = url_for_user(@user, :action => 'link')
    url.should == '/people/link/linkedout'
  end
end
