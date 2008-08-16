require File.dirname(__FILE__) + '/../../spec_helper'

describe Tool::BlogController do
  before do
    @user = create_user
    login_user @user
    controller.stub!(:fetch_page_data)
    controller.stub!(:fetch_wiki)
    @page = create_page(:type => 'Tool::Blog', :name => 'ablog', :created_by => @user)
    @wiki = Blog.new
    @page.stub!(:data).and_return(@wiki)
    @page.data.user = @user
    #controller.instance_variable_set(:@page, @page)
    #controller.instance_variable_set(:@wiki, @wiki)
    controller.stub!(:login_or_public_page_required).and_return(true)
    controller.stub!(:authorized?).and_return(true)
  end
  describe "show" do
    it "should be successful" do
      #@wiki.should_receive(:version).and_return(2)
      get :show, :id => @page
      response.should be_success
    end
  end
  describe "edit" do
    it "should call lock" do
      Tool::Blog.should_receive(:find).and_return(@page)
      @wiki.should_receive(:lock)
      get :edit, :id => @wiki.to_param
    end
  end
  describe "update" do
    describe "when canceling" do
      it "should unlock" do
        Tool::Blog.should_receive(:find).and_return(@page)
        @wiki.should_receive(:unlock)
        put :update, :id => @page, :cancel => true
      end
      it "should redirect to blog url" do
        put :update, :id => @page.to_param, :cancel => true
        response.redirect_url.should == blog_url(@page)
      end
    end
  end
end
