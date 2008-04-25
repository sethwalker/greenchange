class BookmarksController < ApplicationController
  before_filter :login_required
  make_resourceful do
    actions :all
    belongs_to :page
    before(:create) do 
      current_object.user = current_user 
      current_object.page = Page.find params[:page_id]
    end
    response_for :create do |format|
      format.html do 
        flash[:notice] = "Bookmarked this page"
        redirect_to( current_object.page ? tool_page_path(current_object.page) : me_bookmark_path(current_object) )
      end
    end
    response_for :destroy do |format|
      format.html do 
        flash[:notice] = "Removed bookmark"
        redirect_to me_bookmarks_path
      end
    end
  end

  def current_objects
    if @person
      @person.bookmarks.allowed( current_user )
    elsif @me
      @me.bookmarks.allowed(current_user)
    elsif @page
      @page.bookmarks.allowed(current_user)
    else 
      Bookmark.allowed(current_user).find :all
    end
  end

end
