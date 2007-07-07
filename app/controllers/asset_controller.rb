class AssetController < ApplicationController
  prepend_before_filter :fetch_asset, :only => :show
  prepend_before_filter :initialize_asset, :only => :create #maybe we can merge these two filters

  def show
    thumb = nil
    unless @asset.filename == "#{params[:filename]}.#{params[:format]}"
      file = @asset.thumbnails.detect {|a| a.filename == "#{params[:filename]}.#{params[:format]}"}
      thumb = file.thumbnail if file
    end
    send_file(@asset.full_filename(thumb), :type => @asset.content_type, :disposition => (@asset.image? ? 'inline' : 'attachment'))
  end

  def create
    if @asset.save
#      if params[:title] || params[:tag_list]
#        params[:page] = {:title => params[:title]}
#        @page = build_new_page
#        @page.data = @asset
#        @page.save
#      end
      return redirect_to page_url(@asset.page)
    end
  end

#  include Tool::ToolCreation
#  def get_groups
#    @asset.page.groups
#  end
#  def get_page_type
#    Tool::Asset
#  end

  protected

  def fetch_asset
    @asset = Asset.find(params[:id], :include => ['pages', 'thumbnails']) if params[:id]
    if @asset.is_public?
      @asset.update_access 
      redirect_to and return false
    end
  end

  def initialize_asset
    @asset = Asset.new params[:asset]
    suffix = @asset.filename.sub(/^.*\.(.+)$/,'.\\1')
    @asset.filename = params[:asset_title]+suffix if params[:asset_title].any?
    true
  end

  def authorized?
    if @asset
      if action_name == 'show'
        current_user.may?(:read, @asset.page)
      elsif action_name == 'create'
        current_user.may?(:edit, @asset.page)
      end
    else
      false
    end
  end

  def access_denied
    store_location
    message :error => 'You do not have sufficient permission to access that file' if logged_in?
    message :error => 'Please login to access that file.' unless logged_in?
    redirect_to :controller => '/account', :action => 'login'
  end
end

