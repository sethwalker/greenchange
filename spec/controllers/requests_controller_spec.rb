require File.dirname(__FILE__) + '/../spec_helper'

describe RequestsController do
  before do
    login_valid_user
  end

  describe "GET show" do
    before do
      @req = JoinRequest.create :sender => create_valid_user, :requestable => create_valid_group
      JoinRequest.stub!(:find).and_return(@req)
    end
    it "redirects to messages show" do
      get :show, :id => 1
      @response.should redirect_to(message_path(@req))
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
