class Tool::ExternalVideoController < Tool::BaseController
  def new 
    @page = Tool::ExternalVideo.new :group_id => params[:group_id]
  end

  def create
    @page_class = Tool::ExternalVideo
    @page = create_new_page @page_class
    @page.data = ExternalMedia::Youtube.new(params[:external_media])
    if @page.save
      return redirect_to(video_url(@page))
    else
      message :object => @page
    end
#    type = params[:type]
#    if type && klass = const_defined?("ExternalMedia::#{type.camelize}")
#      embed = klass.sanitize(params[:embed])
#    end
  end

  def edit
  end

  def update
  end
end
