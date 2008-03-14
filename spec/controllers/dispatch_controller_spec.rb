require File.dirname(__FILE__) + '/../spec_helper'

describe DispatchController do
  describe "find_pages_with_unknown_context" do
    it "returns some public pages when not logged in" do
      pending "this test breaks cuz there is no request, move function to /lib or delete"
      controller.params = {}
      p = create_valid_page :name => 'pagee', :public => true
      pages = controller.__send__ :find_pages_with_unknown_context, p.name
      pages.should include(p)
    end
  end

  describe "find_controller" do
    it "finds page by id when handle has a space" do
      controller.should_receive(:find_page_by_id).with('5')
      get :dispatch, :_page => 'garble 5'
    end
    it "finds page by id when handle has a plus" do
      controller.should_receive(:find_page_by_id).with('5')
      get :dispatch, :_page => 'garble+5'
    end
  end
end
