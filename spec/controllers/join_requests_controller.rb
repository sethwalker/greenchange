require File.dirname(__FILE__) + '/../spec_helper'

describe JoinRequestsController do
  before do
    login_user(new_user)
  end

  describe "GET show" do
    before do
      @req = JoinRequest.create :sender => create_user, :recipient => create_user, :requestable => create_group
      JoinRequest.stub!(:find).and_return(@req)
    end
    it "checks authorization" do
      @req.should_receive(:allows?)
      get :show, :id => 1
    end
  end

  describe "GET index" do
    before do
      get :index
    end
    it "assigns requests received" do
      assigns[:requests_received].should_not be_nil
    end
    it "assigns requests sent" do
      assigns[:requests_sent].should_not be_nil
    end
  end

  describe "POST create" do
  end
end
