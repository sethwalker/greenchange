class RatingsController < ApplicationController
  before_filter :login_required

  def create
    @page.star!(current_user)
    flash[:notice ] = "Added a star to this page"
    redirect_to tool_page_url(@page)
    
  end

  def destroy
    @page.unstar!(current_user)
    flash[:notice ] = "Removed your star from this page"
    redirect_to tool_page_url(@page)
  end
  
  private

  def load_context
    @page = Page.allowed(current_user).find params[:page_id] if params[:page_id]
  end

end
