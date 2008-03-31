require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/shared'

describe Tool::WikiController do
#  it_should_behave_like "a tool controller"

  before do
    login_valid_user
    controller.stub!(:fetch_page_data)
    controller.stub!(:fetch_wiki)
    @page = create_page(:type => 'Tool::TextDoc', :name => 'awiki')
    @wiki = Wiki.new
    controller.instance_variable_set(:@page, @page)
    controller.instance_variable_set(:@wiki, @wiki)
    controller.stub!(:login_or_public_page_required).and_return(true)
    controller.stub!(:authorized?).and_return(true)
  end
  describe "show" do
    it "should be successful" do
      @wiki.should_receive(:version).and_return(2)
      get :show, :id => @page
      response.should be_success
    end
    it "should redirect if no version" do
      @wiki.should_receive(:version).and_return(0)
      get :show, :id => @page
      response.redirect_url.should == edit_wiki_url(@page)
    end
  end
  describe "edit" do
    it "should call lock" do
      @wiki.should_receive(:lock)
      get :edit, :id => @wiki.to_param
    end
  end
  describe "update" do
    it "should call save_edits" do
      controller.should_receive(:save_edits)
      put :update, :id => @page.to_param
    end
    describe "when canceling" do
      it "should unlock" do
        @wiki.should_receive(:unlock)
        put :update, :id => @page.to_param, :cancel => true
      end
      it "should redirect to wiki url" do
        put :update, :id => @page.to_param, :cancel => true
        response.redirect_url.should == wiki_url(@page)
      end
    end
  end
  describe "diff route" do
    it "should be named" do
      get :show, :id => @page #hack to set up controller
      diff_wiki_path(@page, :from => '2', :to => '3').should == "/wikis/#{@page.to_param}/diff?from=2&to=3"
    end
  end
  describe "break_lock route" do
    it "should recognize" do
      params_from(:post, "/wikis/#{@page.to_param}/break_lock").should == {:controller => 'tool/wiki', :action => 'break_lock', :id => @page.to_param}
    end
  end
  describe "new" do
    it "should set @page" do
      get :new
      assigns[:page].should be_a_kind_of(Tool::TextDoc)
    end
    it "should set @wiki" do
      get :new
      assigns[:wiki].should be_a_kind_of(Wiki)
    end
  end
  describe "create" do
    before do
      post :create, :page => {:title => 'thetitle'}, :wiki => {:body => "thebody"}
    end
    it "should create page" do
      assigns[:page].should be_valid
    end
    it "should create wiki" do
      assigns[:page].data.body.should == 'thebody'
    end
  end
end
