require File.dirname(__FILE__) + '/../spec_helper'

describe MeController do
  before do
    login_user(@current_user = new_user)
  end
  describe "GET #show" do
    it "should be tested" do
      pending
    end
  end
end
