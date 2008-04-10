class Tool::DiscussionController < Tool::BaseController

  #def new
  #  @page = Tool::Discussion.new :group_id => params[:group_id]
  #end

  #def show
  #  @comment_header = ""
  #end
  
  protected

  def setup_data(page_data)
    if page_data && page_data[:new_post] && page_data[:new_post].any? { |v| !v.blank? }
      page_data[:new_post][:user_id] = current_user.id
    end
    page_data
  end
  
  #def setup_view
  #  @show_reply = true
  #end
  
end
