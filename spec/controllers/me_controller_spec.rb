require File.dirname(__FILE__) + '/../spec_helper'

describe MeController do
  before do
    @user = login_valid_user
  end
  describe "search" do
    it "should set @pages" do
      get :search
      assigns[:pages].should_not be_nil
    end
    it "@pages should be a paginated collection" do
      get :search
      assigns[:pages].should be_a_kind_of(WillPaginate::Collection)
    end
  end

  describe "files" do
    it "should set @pages" do
      get :files
      assigns[:pages].should_not be_nil
    end
  end

  describe "tasks" do
    it "shouldn't raise an error" do
      lambda { get :tasks }.should_not raise_error
    end
  end
end
