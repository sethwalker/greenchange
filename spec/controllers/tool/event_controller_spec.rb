require File.dirname(__FILE__) + '/../../spec_helper'

describe Tool::EventController do
  describe "show" do
    before do
      current_user = login_valid_user
      @page = Tool::Event.create :title => 'event'
      @page.build_data :is_all_day => true, :page => @page
      @page.save!
      current_user.stub!(:may!).and_return true
      Tool::Event.stub!(:find).and_return @page
    end
    it "should be successful" do
      get :show, :id => @page.to_param
      response.should be_success
    end
  end
end
