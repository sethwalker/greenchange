require File.dirname(__FILE__) + '/../spec_helper'

describe PostsController do
  it "should be tested properly" do
    pending
  end
  describe "create" do
    before do
      login_user(@user = create_user)
      @user.stub!(:may!).and_return(true)
    end
    def act!
      @page = create_page
      post :create, :post => {:body => 'test post'}, :page_id => @page.id
    end
    it "should create post" do
      lambda {act!}.should change(Post, :count)
    end
    it "should be redirect" do
      act!
      response.should be_redirect
    end
    it "should redirect to page url" do
      act!
      response.should redirect_to(page_url(@page))
    end
    it "should list the user as a contributor" do
      act!
      @page.discussion(true).posts(true)
      @page.contributors.should include(@user)
    end
  end
end
