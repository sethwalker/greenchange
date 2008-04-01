class Tool::DiscussionController < Tool::BaseController

  def new
    @page = Tool::Discussion.new :group_id => params[:group_id]
  end

  def show
    @comment_header = ""
  end
  
  protected
  
  def setup_view
    @show_reply = true
  end
  
end
