require File.dirname(__FILE__) + '/../spec_helper'

describe PostsController do
  it "should be tested properly" do
    pending
  end
  describe "create" do
    before do
      login_user create_user
      page = create_page
      post :create, :post_body => 'test post', :page_id => page.id
    end
    it "should be success" do
      pending do
        response.should be_success
      end
    end
  end
end
