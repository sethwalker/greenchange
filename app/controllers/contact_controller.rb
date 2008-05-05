#
# a controller for managing contacts
#

class ContactController < ApplicationController

  before_filter :login_required
  prepend_before_filter :fetch_person, :except => [:requests, :approve, :reject]
  before_filter :find_contact_request, :only => [:requests, :approve, :reject]
  
  def new
    render :action => 'add'
  end
  alias :add :new 

  def create
    req = ContactRequest.find_or_initialize_by_user_id_and_contact_id(current_user.id, @person.id)
    req.message = params[:message] if params[:message]
    if req.save
      message :success => 'Your contact request has been sent to %s.' / @person.login
      redirect_to person_url(@person)
    else
      message :object => req
      render :action => 'add'
    end
  end

  def index
    #@people = @contacts = User.by_group(@group).by_person(( @me || @person)).by_issue(@issue).by_tag(@tag)
    @contacts = User.by_person(@person).find :all #.by_person(( @me || @person)).by_issue(@issue).by_tag(@tag)
  end
  
  def remove
  end

  def destroy
    current_user.contacts.delete(@person)
    message :success => '%s has been removed from your contact list.' / @person.login
    redirect_to person_url(@person)
  end

  def requests
  end

  def approve
    if @contact_request.approve!
      flash[:notice] = "#{@contact_request.user.login} is now your contact" 
      redirect_to me_inbox_path
    else
      @contact_request.destroy
      flash[:error] = "The contact request is invalid and has been deleted.  Please try again"
      redirect_to me_inbox_path
      #message :object => @contact_request
      #render :action => 'requests'
    end
  end

  def reject
    if @contact_request.reject!
      flash[:notice] = "Contact request from #{@contact_request.user.login} declined" 
      redirect_to me_inbox_path
    else
      @contact_request.destroy
      flash[:error] = "The contact request is invalid, deleting it"
      redirect_to me_inbox_path
    end
  end

  protected

  def find_contact_request
    @contact_request = ContactRequest.find(params[:id])
    raise PermissionDenied unless @contact_request.contact == current_user
  end
  
  def fetch_person
    @person ||= User.find_by_login params[:id] if params[:id]
    true
  end
  
end

