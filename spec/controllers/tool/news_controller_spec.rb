require File.dirname(__FILE__) + '/../../spec_helper'

describe Tool::NewsController do
  before do
    login_valid_user
    controller.stub!(:fetch_page_data)
    controller.stub!(:fetch_wiki)
    @page = create_page(:type => 'Tool::News', :name => 'anews')
    @wiki = News.new
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
        response.should redirect_to(news_url(@page))
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
      params_from(:get, "/news/#{@page.to_param}/versions").should == {:controller => 'tool/news', :action => 'versions', :id => @page.to_param}
    end
    it "should generate" do
      pending do
      route_for(:controller => 'tool/news', :action => 'versions', :id => @page).should == "/news/#{@page.to_param}/versions"
      end
    end
    it "should be named" do
      get :show, :id => @page #hack to set up controller
      versions_news_path(@page).should == "/news/#{@page.to_param}/versions"
    end
  end

  describe "diff route" do
    it "should be named" do
      get :show, :id => @page #hack to set up controller
      diff_news_path(@page, :from => '2', :to => '3').should == "/news/#{@page.to_param}/diff?from=2&to=3"
    end
  end
end
