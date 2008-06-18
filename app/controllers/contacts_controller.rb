#
# a controller for managing contacts
#

class ContactsController < ApplicationController

  before_filter :login_required
  
  def new
    redirect_to new_person_invitation_path(@person)
  end

  def index
    @contacts = User.enabled.by_person(@me||@person).find :all 
  end
  
  def destroy
    @contact = Contact.find params[:id]
    current_user.may! :admin, @contact
    @contact.destroy
    flash[:notice] = "#{@contact.contact.display_name} has been removed from your contact list." 
    redirect_to me_contacts_path
  end

end
