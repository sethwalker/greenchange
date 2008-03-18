#
# a controller for managing contacts
#

class ContactController < ApplicationController

  before_filter :login_required
  prepend_before_filter :fetch_person, :except => [:requests, :approve, :reject]
  before_filter :find_contact_request, :only => [:requests, :approve, :reject]
  #layout 'person'  
  
  def add
  end

  def create
    req = ContactRequest.find_or_initialize_by_user_id_and_contact_id(current_user.id, @person.id)
    req.message = params[:message] if params[:message]
    if req.save
      message :success => 'Your contact request has been sent to %s.' / @person.login
      redirect_to url_for_user(@person)
    else
      message :object => req
      render :action => 'add'
    end
  end
  
  def remove
  end

  def destroy
    current_user.contacts.delete(@person)
    message :success => '%s has been removed from your contact list.' / @person.login
    redirect_to url_for_user(@person)
  end

  def requests
  end

  def approve
    if @contact_request.approve!
      message :text => 'request approved'
      redirect_to :action => 'requests', :id => @contact_request #or ajax, or somewhere that makes sense
    else
      message :object => @contact_request
      render :action => 'requests'
    end
  end

  def reject
    if @contact_request.reject!
      message :text => 'request rejected'
      redirect_to :action => 'requests', :id => @contact_request #or ajax, or somewhere that makes sense
    else
      message :object => @contact_request
      render :action => 'requests'
    end
  end

  protected

  def find_contact_request
    @contact_request = ContactRequest.find(params[:id])
    return access_denied unless @contact_request.user == current_user
  end
  
  def fetch_person
    @person ||= User.find_by_login params[:id] if params[:id]
    true
  end
  
  def context
    person_context
    add_context 'contact', url_for(:controller => 'contact', :action => 'add', :id => @person)
  end
  
end

