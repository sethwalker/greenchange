require File.dirname(__FILE__) + '/../test_helper'
require 'bookmarks_controller'

# Re-raise errors caught by the controller.
class BookmarksController; def rescue_action(e) raise e end; end

class BookmarksControllerTest < Test::Unit::TestCase
  fixtures :bookmarks

  def setup
    @controller = BookmarksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bookmarks)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_bookmark
    old_count = Bookmark.count
    @controller.stubs(:current_user).returns(User.find_by_login 'quentin')
    post :create, :bookmark => { }
    assert_equal old_count + 1, Bookmark.count

    assert_redirected_to bookmark_path(assigns(:bookmark))
  end

  def test_should_show_bookmark
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_bookmark
    put :update, :id => 1, :bookmark => { }
    assert_redirected_to bookmark_path(assigns(:bookmark))
  end

  def test_should_destroy_bookmark
    old_count = Bookmark.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Bookmark.count

    assert_redirected_to bookmarks_path
  end
end
