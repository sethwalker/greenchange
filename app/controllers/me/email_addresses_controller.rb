class Me::EmailAddressesController < ApplicationController
  before_filter :login_required

  def new
    @email_address = Profile::EmailAddress.new
    if request.xhr?
      render :partial => 'me/profiles/email_address', :locals => { :email_address => @email_address }
    end
  end

  def destroy
    @email = Profile::EmailAddress.find params[:id]
    @email.destroy   
    
    
    respond_to do |format|
      format.html do
        flash[:notice] = "#{@email.email_address} deleted"
        redirect_to me_profile_path
      end 
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
end
