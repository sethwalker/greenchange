require File.dirname(__FILE__) + '/../../spec_helper'

describe Tool::EventController do
  describe "show" do
    before do
      login_valid_user
      @page = Tool::Event.create :title => 'event'
    end
    it "should be successful" do
      get :show, :id => @page.to_param
      response.should be_success
    end
  end
end
