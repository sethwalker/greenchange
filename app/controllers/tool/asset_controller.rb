class Tool::AssetController < Tool::BaseController
  before_filter :fetch_asset

#  def show
#  end
#
#  # note, massive duplication both here and in the view
#  def new 
#    @page = Tool::Asset.new :group_id => params[:group_id]
#  end
#
#  def create
#    #@page_class = Tool::Asset
#    @asset = Asset.new params[:asset]
#    @page_class = Tool.const_get( @asset.display_class )#page_class_from_asset( @asset ))
#    @page = create_new_page(@page_class)
#    @page.data = @asset
#    if @page.title.any?
#      @asset.filename = @page.title + @asset.suffix
#    else
#      @page.title = @asset.basename
#    end
#    if @page.save
#      @page.tag_with(params[:tag_list]) if params[:tag_list]
#      params[:issues].each do |issue_id|
#        @page.issue_identifications.create :issue_id => issue_id
#      end
#      add_participants!(@page, params)
#      return redirect_to(upload_url(@page))
#    else
#      message :object => @page
#    end
#  end

#  def update
#    @page.data.uploaded_data = params[:asset]
#    @page.data.filename = @page.title + @page.data.suffix
#    if @page.data.save
#      return redirect_to(upload_url(@page))
#    else
#      message :object => @page
#    end
#  end
#
  def destroy_version
    @page = Tool::Asset.find params[:id]
    asset_version = @page.data.versions.find_by_version(params[:version])
    asset_version.destroy
    respond_to do |format|
      format.html do
        message(:success => "file version deleted")
        redirect_to(upload_url(@page))
      end
      format.js { render(:update) {|page| page.visual_effect :fade, "asset_#{asset_version.asset_id}_version_#{asset_version.version}", :duration => 0.5} }
    end
  end

  protected
  
  def fetch_asset
    @asset = @page.data if @page
  end

  def setup_data(values)
    if @page.title && @page.data && values
      values[:filename] = @page.title + @page.data.suffix
    end
    values
  end
  
  def setup_view
    @show_posts = true
  end
  
end
