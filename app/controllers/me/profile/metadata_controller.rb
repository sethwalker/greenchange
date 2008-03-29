class Me::Profile::MetadataController < ApplicationController
  before_filter :login_required

  def item_partial
    controller_name.singularize.to_sym
  end

  def new
    @item = ::Profile.const_get(controller_name.demodulize.classify).new
    if request.xhr?
      render :partial => "me/profiles/sections/#{item_partial}", :locals => { item_partial => @item }
    end
  end

  def destroy
    @item = ::Profile.const_get(controller_name.demodulize.classify).find params[:id]
    @item.destroy   
    
    
    respond_to do |format|
      format.html do
        flash[:notice] = "#{@item} deleted"
        redirect_to edit_me_profile_path
      end 
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
end
