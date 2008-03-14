require File.dirname(__FILE__) + '/../spec_helper'

describe "SocialUser with permissions" do
  before do
    @user = create_valid_user
    @group = create_valid_group

    @group_page  = Page.new(:public => true)
  end

  it "should be allowed to view public pages" do
    @group.memberships.create :user => @user, :role => :member
    @group_page.group = @group

    @user.should be_allowed_to(:view, @group_page)
  end
end
