require File.dirname(__FILE__) + '/../spec_helper'

describe "SocialUser" do
  
  before do
    @user = create_valid_user
    
  end

  it "should update groups array when changes happen" do
    @user.groups
    group = Group.create :name => 'hogwarts-academy'
    group.memberships.create :user => @user
    @user.group_ids.should == [ group.id ]
  end
  it "should update the all-groups array when changes happen" do
    #@user.group_ids
    #@user.all_group_ids
    #@user.groups
    @user.all_groups
    group = Group.create :name => 'hogwarts-academy'
    group.memberships.create :user => @user
    #@user.all_group_ids
    @user.all_group_ids.should == [ group.id ]
  end

  it "should be able to access pending pages" do
    p = create_valid_page
    @user.pages << p
    @user.participations.detect {|up| up.page_id = p.id }.update_attribute :resolved, false
    @user.pages_pending.should include(p)
  end

end
