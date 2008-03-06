require File.dirname(__FILE__) + '/../../test_helper'
require 'tool/blog_controller'

# Re-raise errors caught by the controller.
class Tool::BlogController; def rescue_action(e) raise e end; end

class Tool::BlogControllerTest < Test::Unit::TestCase

  def setup
    @controller = Tool::BlogController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_show
    @page = Page.new(:title => 'a page', :public => false)
    @page.data = Blog.new(:body => 'new page')
    @page.save
    @controller.stubs(:logged_in?).returns(true)
    @controller.stubs(:current_user).returns(stub(:may? => true, :banner_style => Style.new, :time_zone => nil, :avatar => nil, :contacts => [], :groups => [], :viewed => true, :display_name => 'a name', :bookmarked? => true ))
    get :show, :controller => 'tool/blog_controller', :page_id => @page.id
    assert_response :success
    assert_template 'show'
  end

end
