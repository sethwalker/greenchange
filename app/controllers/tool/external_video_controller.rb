class Tool::ExternalVideoController < Tool::BaseController
  def new 
    @page = Tool::ExternalVideo.new :group_id => ( @group ? @group.id : nil ), :public => true, :public_participate => true
    @page.build_data
  end

  def create
#    new hotness -----------------------------------------------|
    page_data = params[:page].delete(:page_data )
    @page = Tool::ExternalVideo.new params[:page]
    @page.build_data page_data
    @page.created_by = current_user
    #raise @page.issue_ids.inspect
    #raise @page.instance_variable_get("@new_issues".to_sym).inspect
    #raise params[:page][:page_data ].inspect
    #raise @page.read_attribute( :page_data ).inspect
  
    if @page.save
      flash[:notice] = 'Created new page'
      redirect_to video_url(@page)
    else
      #raise @page.errors.inspect
      render :action => 'new'
    end

#    @page = create_new_page @page_class
#    @page.data = ExternalMedia::Youtube.new(params[:external_media])
#    if @page.save
#      @page.tag_with(params[:tag_list]) if params[:tag_list]
#      params[:issues].each do |issue_id|
#        @page.issue_identifications.create :issue_id => issue_id
#      end
#      add_participants!(@page, params)
#      return redirect_to(video_url(@page))
#    else
#      message :object => @page
#    end
#    type = params[:type]
#    if type && klass = const_defined?("ExternalMedia::#{type.camelize}")
#      embed = klass.sanitize(params[:embed])
#    end
  end

  def edit
    @page = Tool::ExternalVideo.find( params[:id] )
  end

  def update
    @page = Tool::ExternalVideo.find( params[:id] )
    @page.update_attributes params[:page]
    @page.updated_by = current_user
    if @page.save
      flash[:notice] = 'Page has been updated'
      redirect_to video_url(@page)
    else
      render :action => 'edit'
    end
  end
end
