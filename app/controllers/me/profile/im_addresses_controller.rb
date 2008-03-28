class Me::Profile::ImAddressesController < Me::Profile::MetadataController 
end
#  before_filter :login_required
#
#  def new
#    @im_address = ::Profile::ImAddress.new
#    if request.xhr?
#      render :partial => 'me/profiles/im_address', :locals => { :im_address => @im_address }
#    end
#  end
#
#  def destroy
#    @im = ::Profile::ImAddress.find params[:id]
#    @im.destroy   
#    
#    
#    respond_to do |format|
#      format.html do
#        flash[:notice] = "#{@im.im_address} deleted"
#        redirect_to me_profile_path
#      end 
#      format.xml  { head :ok }
#      format.json { head :ok }
#    end
#  end
#end
#
