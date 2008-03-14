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
end
