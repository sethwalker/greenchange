class Profile::MetadataController < ApplicationController
  before_filter :login_required
  before_filter :fetch_profile

  def item_partial
    controller_name.singularize.to_sym
  end

  def new
    @item = ::Profile.const_get(controller_name.demodulize.classify).new
    if request.xhr?
      render :partial => "profiles/sections/#{item_partial}", :locals => { item_partial => @item }
    end
  end

  def destroy
    @item = ::Profile.const_get(controller_name.demodulize.classify).find params[:id]
    @item.destroy   
    
    
    respond_to do |format|
      format.html do
        flash[:notice] = "#{@item} deleted"
        redirect_to edit_person_profile_path(@profile.entity)
      end 
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end

  protected
  
  def fetch_profile
    @profile = Profile.find params[:profile_id]
    @profile && current_user.may!( :admin, @profile )
  end
end
