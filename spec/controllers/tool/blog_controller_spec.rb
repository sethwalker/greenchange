require File.dirname(__FILE__) + '/../../spec_helper'

describe Tool::BlogController do
  before do
    login_valid_user
    controller.stub!(:fetch_page_data)
    controller.stub!(:fetch_wiki)
    @page = create_page(:type => 'Tool::Blog', :name => 'ablog')
    @wiki = Blog.new
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
      response.redirect_url.should == edit_blog_url(@page)
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
      it "should redirect to blog url" do
        put :update, :id => @page.to_param, :cancel => true
        response.redirect_url.should == blog_url(@page)
      end
    end
  end
end
