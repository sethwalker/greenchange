require File.dirname(__FILE__) + '/../spec_helper'

describe MeController do
  describe "search" do
    before do
      @user = login_valid_user
    end
    it "should set @pages" do
      get :search
      assigns[:pages].should_not be_nil
    end
    it "@pages should be a paginated collection" do
      get :search
      assigns[:pages].should be_a_kind_of(WillPaginate::Collection)
    end
  end
end
