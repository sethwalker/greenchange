class RecommendationsController < MessagesController
  append_view_path "#{RAILS_ROOT}/app/views/messages"

  def new
    super
    @page = Page.find params[:page_id]
    @message.body = "Check out #{page_url(@page)}"
  end

  def create
    @page = Page.find params[:page_id]
    @page.star! current_user 
    super
  end

end
