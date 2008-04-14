class AttendeesController < ApplicationController
  before_filter :login_required

  def create
    @page = Page.find params[:event_id]
    participation = @page.user_participations.find_or_create_by_user_id current_user.id
    if participation.update_attributes( :attend => true )
      flash[:notice] = "You are now registered"
    else
      flash[:notice] = "Sorry, you cannot register"
    end
    redirect_to tool_page_path(@page)
  end

  def destroy
    @page = Page.find params[:event_id]
    participation = @page.user_participations.find_or_create_by_user_id current_user.id
    if participation.update_attributes( :attend => false )
      flash[:notice] = "You are no longer registered"
    else
      flash[:notice] = "Sorry, cancellation failed"
    end
    redirect_to tool_page_path(@page)
  end
end
