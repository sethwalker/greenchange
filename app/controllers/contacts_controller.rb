#
# a controller for managing contacts
#

class ContactsController < ApplicationController

  before_filter :login_required
  #prepend_before_filter :fetch_person, :except => [:requests, :approve, :reject]
  #before_filter :find_contact_request, :only => [:requests, :approve, :reject]
  
  def new
    redirect_to new_person_invitation_path(@person)
  end
#  alias :add :new 
#
#  def create
#    req = ContactRequest.find_or_initialize_by_user_id_and_contact_id(current_user.id, @person.id)
#    req.message = params[:message] if params[:message]
#    if req.save
#      message :success => 'Your contact request has been sent to %s.' / @person.login
#      redirect_to person_url(@person)
#    else
#      message :object => req
#      render :action => 'add'
#    end
#  end

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

#  def remove
#  end
#
#  def requests
#  end
#
#  def approve
#    if @contact_request.approve!
#      flash[:notice] = "#{@contact_request.user.login} is now your contact" 
#      redirect_to me_inbox_path
#    else
#      @contact_request.destroy
#      flash[:error] = "The contact request is invalid and has been deleted.  Please try again"
#      redirect_to me_inbox_path
#      #message :object => @contact_request
#      #render :action => 'requests'
#    end
#  end
#
#  def reject
#    if @contact_request.reject!
#      flash[:notice] = "Contact request from #{@contact_request.user.login} declined" 
#      redirect_to me_inbox_path
#    else
#      @contact_request.destroy
#      flash[:error] = "The contact request is invalid, deleting it"
#      redirect_to me_inbox_path
#    end
#  end
#
#  protected
#
#  def find_contact_request
#    @contact_request = ContactRequest.find(params[:id])
#    raise PermissionDenied unless @contact_request.contact == current_user
#  end
#  
#  def fetch_person
#    @person ||= User.find_by_login params[:id] if params[:id]
#    true
#  end
#  
end

