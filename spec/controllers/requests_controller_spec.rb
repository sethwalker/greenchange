require File.dirname(__FILE__) + '/../spec_helper'

describe RequestsController do
  before do
    login_valid_user
  end
  describe "contacts" do
    it "should paginate the collection" do
      get :contacts
      assigns[:requests].should be_a_kind_of(WillPaginate::Collection)
    end
  end
  describe "memberships" do
    it "should paginate the collection" do
      get :memberships, :path => ['created_at', 'descending']
      assigns[:requests].should be_a_kind_of(WillPaginate::Collection)
    end
  end
  describe "mine" do
    it "should paginate the collection" do
      get :mine, :path => ['created_at', 'descending']
      assigns[:requests].should be_a_kind_of(WillPaginate::Collection)
    end
  end
  describe "index" do
    it "should paginate the collections" do
      get :index
      assigns[:my_contact_requests_sent].should_not be_nil
      assigns[:my_contact_requests_received].should_not be_nil
      assigns[:my_membership_requests].should_not be_nil
    end
  end

end
