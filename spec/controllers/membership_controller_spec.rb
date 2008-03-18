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
      get :requests, :id => @group.name
      assigns[:requests].should_not be_nil
    end
    it "should be a paginated collection" do
      get :requests, :id => @group.name
      assigns[:requests].should be_a_kind_of(WillPaginate::Collection)
    end
  end
end
