class Tool::MessageController < Tool::BaseController

  def show
    @comment_header = ""
  end

  def new
  end

  def create
    users = params[:to].split(/\s+/).uniq.collect do |name|
      User.find_by_login name
    end.compact

    return message(:error => 'title must not be empty'.t) unless params[:title].any?
    return message(:error => 'at least one recipient is required'.t) unless users.any?
    return message(:error => 'message must not be empty'.t) unless params[:message].any?
      
    page = Page.make :private_message, :to => users, :from => current_user, :title => params[:title], :body => params[:message]
    
    return message(:object => page.discussion.posts.first) unless page.discussion.posts.first.valid?
    return message(:object => page.discussion) unless page.discussion.valid?
    return message(:object => page) unless page.valid?
    
    page.save!
    redirect_to message_url(page)
  end
    
  protected
  
  def setup_view
    @show_reply = true
  end
  
end
