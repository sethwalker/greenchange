class Tool::ExternalVideoController < Tool::BaseController

#  def create
##    new hotness -----------------------------------------------|
#    page_data = params[:page].delete(:page_data )
#    @page = Tool::ExternalVideo.new params[:page]
#    @page.build_data page_data
#    @page.created_by = current_user
#  
#    if @page.save
#      flash[:notice] = 'Created new page'
#      redirect_to video_url(@page)
#    else
#      render :action => 'new'
#    end
#
#  end
#
#  def edit
#    @page = Tool::ExternalVideo.find( params[:id] )
#  end
#
#  def update
#    @page = Tool::ExternalVideo.find( params[:id] )
#    @page.update_attributes params[:page]
#    @page.updated_by = current_user
#    if @page.save
#      flash[:notice] = 'Page has been updated'
#      redirect_to video_url(@page)
#    else
#      render :action => 'edit'
#    end
#  end
end
