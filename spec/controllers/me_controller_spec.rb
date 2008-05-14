require File.dirname(__FILE__) + '/../spec_helper'

describe MeController do
  before do
    @current_user = login_valid_user
  end
  describe "GET #show" do
    it "assigns a list of pages" do
      get :show
      assigns[:pages].should_not be_nil
    end
  end
end
