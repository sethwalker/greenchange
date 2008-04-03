class Tool::ExternalVideoController < Tool::BaseController
  def new 
    @page = Tool::ExternalVideo.new :group_id => params[:group_id]
  end

  def create
#    new hotness -----------------------------------------------|
#    @page = Tool::ExternalVideo.new params[:page]              |
#    @page.created_by = current_user                   <--------|

    @page = create_new_page @page_class
    @page.data = ExternalMedia::Youtube.new(params[:external_media])
    if @page.save
      @page.tag_with(params[:tag_list]) if params[:tag_list]
      params[:issues].each do |issue_id|
        @page.issue_identifications.create :issue_id => issue_id
      end
      add_participants!(@page, params)
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
