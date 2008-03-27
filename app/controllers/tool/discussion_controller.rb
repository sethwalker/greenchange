class Tool::DiscussionController < Tool::BaseController

  def new
    @page = Tool::Discussion.new :group_id => params[:group_id]
  end

  def create
    @page = Tool::Discussion.new params[:page]
    @page.created_by = current_user
    if @page.save
      @page.tag_with(params[:tag_list]) if params[:tag_list]
      redirect_to(discussion_url(@page))
    else
      message :object => @page
      render :action => 'new'
    end
  end

  def show
    @comment_header = ""
  end
  
  protected
  
  def setup_view
    @show_reply = true
  end
  
end
