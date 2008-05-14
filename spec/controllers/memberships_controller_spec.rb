require File.dirname(__FILE__) + '/../spec_helper'

describe MembershipsController do
  before do
    @user = login_valid_user
    @group = create_valid_group
    Group.stub!(:find_by_name).and_return(@group)
  end

  describe "new" do
    it "creates a membership if there are none" do
      get :new, :group_id => @group
      Membership.find_by_user_id_and_group_id(@user.id, @group.id).should_not be_nil
    end
    it "redirects to a join request page if there are memberships" do
      @group.memberships.create :user => create_user
      #MembershipRequest.should_receive(:find_by_user_id_and_group_id).with(@user.id, @group.id).and_return(MembershipRequest.create(:user => @user, :group => @group))
      get :new, :group_id => @group
      response.should redirect_to( new_group_join_request_path(@group) )
    end
  end

  describe "destroy" do
    it "destroys the membership" do
      new_mbrship = @group.memberships.create :user => @user
      post :destroy, :group_id => @group.name, :id => new_mbrship.id
      @group.users.should_not include(@user)
    end
  end


end
