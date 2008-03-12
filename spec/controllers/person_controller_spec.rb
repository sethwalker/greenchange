require File.dirname(__FILE__) + '/../spec_helper'

describe PersonController do
  before do
    login_valid_user
    @user = create_valid_user :login => 'person'
  end
  describe "tasks" do
    it "should set @pages" do
      get :tasks, :id => @user.login
      assigns[:pages].should_not be_nil
    end
  end
end
