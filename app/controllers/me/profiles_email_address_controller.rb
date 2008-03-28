class Me::ProfileEmailAddressController < ApplicationController
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
