require File.dirname(__FILE__) + '/../../spec_helper'

describe Tool::ActionAlertController do
  before do
    login_valid_user
    controller.stub!(:fetch_page_data)
    controller.stub!(:fetch_wiki)
    @page = create_page(:type => 'Tool::ActionAlert', :name => 'anaction')
    @wiki = ActionAlert.new
    controller.instance_variable_set(:@page, @page)
    controller.instance_variable_set(:@wiki, @wiki)
    controller.stub!(:login_or_public_page_required).and_return(true)
    controller.stub!(:authorized?).and_return(true)
  end
  describe "update" do
    describe "when canceling" do
      it "should unlock the wiki" do
        @wiki.should_receive(:unlock)
        put :update, :cancel => true
      end
      it "should redirect to the page url" do
        put :update, :cancel => true
        response.should redirect_to(action_url(@page))
      end
    end
  end
  describe "show" do
    it "should be successful" do
      @wiki.should_receive(:version).and_return(2)
      get :show, :id => @page
      response.should be_success
    end
  end

  describe "versions route" do
    it "should recognize" do
      params_from(:get, "/actions/#{@page.to_param}/versions").should == {:controller => 'tool/action_alert', :action => 'versions', :id => @page.to_param}
    end
    it "should generate" do
      pending do
      route_for(:controller => 'tool/action_alert', :action => 'versions', :id => @page).should == "/actions/#{@page.to_param}/versions"
      end
    end
    it "should be named" do
      get :show, :id => @page #hack to set up controller
      versions_action_path(@page).should == "/actions/#{@page.to_param}/versions"
    end
  end

  describe "diff route" do
    it "should be named" do
      get :show, :id => @page #hack to set up controller
      diff_action_path(@page, :from => '2', :to => '3').should == "/actions/#{@page.to_param}/diff?from=2&to=3"
    end
  end
end
