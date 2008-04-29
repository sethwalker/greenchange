require File.dirname(__FILE__) + '/../spec_helper'

describe MembershipController do
  before do
    @user = login_valid_user
    @group = create_valid_group
  end

  describe "requests" do
    before do
      @group.memberships.create :user => @user
    end
    it "assigns pages" do
      get :requests, :group_id => @group.name
      assigns[:requests].should_not be_nil
    end
    it "should be a paginated collection" do
      get :requests, :group_id => @group.name
      assigns[:requests].should be_a_kind_of(WillPaginate::Collection)
    end
  end

  describe "create" do
    it "creates a membership if there are none" do
      post :create, :group_id => @group.name
      Membership.find_by_user_id_and_group_id(@user.id, @group.id).should_not be_nil
    end
    it "creates a membership request if there are memberships" do
      @group.memberships.create :user => create_user
      MembershipRequest.should_receive(:find_by_user_id_and_group_id).with(@user.id, @group.id).and_return(MembershipRequest.create(:user => @user, :group => @group))
      post :create, :group_id => @group.name
    end
  end

  describe "destroy" do
    it "destroys the membership" do
      new_mbrship = @group.memberships.create :user => @user
      post :destroy, :group_id => @group.name, :id => new_mbrship.id
      @group.users.should_not include(@user)
    end
  end

  describe "update" do
    it "should be tested, cause it's weird" do
      pending
    end
  end

  describe "invite" do
    before do
      @group.memberships.create :user => @user
      @first_invitee = create_user
      @second_invitee = create_user
    end
    it "should find the users" do
      User.should_receive(:find_by_login).with(@first_invitee.login)
      User.should_receive(:find_by_login).with(@second_invitee.login)
      post :send_invitation, :group_id => @group.name, :invitation => { :user_names => "#{@first_invitee.login} #{@second_invitee.login}" }
    end
    it "should create membership requests" do
      MembershipRequest.should_receive(:find_or_initialize_by_user_id_and_group_id).with(@first_invitee.id, @group.id).and_return(MembershipRequest.new(:user => @first_invitee, :group => @group))
      MembershipRequest.should_receive(:find_or_initialize_by_user_id_and_group_id).with(@second_invitee.id, @group.id).and_return(MembershipRequest.new(:user => @second_invitee, :group => @group))
      post :send_invitation, :group_id => @group.name, :invitation => { :user_names => "#{@first_invitee.login} #{@second_invitee.login}" }
    end
  end

  describe "approve" do
    before do
      controller.stub!(:authorized?).and_return(true)
    end
    it "should approve" do
      m = MembershipRequest.create :group => @group, :user => create_user
      m.should_receive(:approve!)
      @group.stub!(:allows?).and_return(true)
      MembershipRequest.should_receive(:find).and_return(m)
      post :approve, :id => m.id
    end
  end

  describe "reject" do
    before do
      controller.stub!(:authorized?).and_return(true)
    end
    it "should reject" do
      @group.stub!(:allows?).and_return(true)
      m = MembershipRequest.create :group => @group, :user => create_user
      m.should_receive(:reject!)
      MembershipRequest.should_receive(:find).and_return(m)
      post :reject, :id => m.id
    end
  end
end
