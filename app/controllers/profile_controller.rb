class ProfileController < ApplicationController

  before_filter :login_required
  prepend_before_filter :fetch_profile
  #layout :choose_layout
  
  def show
    
  end

  def edit
    if request.post?
      @profile.save_from_params params['profile']
      @entity.issue_ids = params['issues']
    end
  end

  # ajax
  def add_location
    render :update do |page|
      page.insert_html :bottom, 'profile_locations', :partial => 'location', :locals => {:location => Profile::Location.new}
    end
  end

  # ajax
  def add_email_address
    render :update do |page|
      page.insert_html :bottom, 'profile_email_addresses', :partial => 'email_address', :locals => {:email_address => Profile::EmailAddress.new}
    end
  end

  # ajax
  def add_im_address
    render :update do |page|
      page.insert_html :bottom, 'profile_im_addresses', :partial => 'im_address', :locals => {:im_address => Profile::ImAddress.new}
    end
  end

  def add_web_service
   render :update do |page|
    page.insert_html :bottom, 'profile_web_services', :partial => 'web_service', :locals => {:web_service => Profile::WebService.new}
    end
  end

  # ajax
  def add_phone_number
    render :update do |page|
      page.insert_html :bottom, 'profile_phone_numbers', :partial => 'phone_number', :locals => {:phone_number => Profile::PhoneNumber.new}
    end
  end

  # ajax
  def add_note
    render :update do |page|
      page.insert_html :bottom, 'profile_notes', :partial => 'note', :locals => {:note => Profile::Note.new}
    end
  end

  # ajax
  def add_website
    render :update do |page|
      page.insert_html :bottom, 'profile_websites', :partial => 'website', :locals => {:website => Profile::Website.new}
    end
  end

  protected
 
  def fetch_profile
    #return true unless params[:id]
    if params[:group_id]
      @entity = @group = Group.find(params[:group_id])
      @profile = @group.profile
    else
      @entity = @user = current_user
      @profile = current_user.private_profile || current_user.build_private_profile
    end
    #@entity = @profile.entity
    #if @entity.is_a?(User)
    #  @user = @entity
    #if @entity.is_a?(Group)
    #  @group = @entity
    #else
    #  raise Exception.new("could not determine entity type for profile: #{@profile.inspect}")
    #end
  end
  
  # always have access to self
  def authorized?
    if @entity.is_a?(User) and current_user == @entity
      return true
    elsif @entity.is_a?(Group)
      return true if action_name == 'show'
      return true if logged_in? and current_user.may?( :admin, @entity)
      return false
    elsif action_name =~ /add_/
     return true # TODO: this is the right way to do this
    end
#    if @entity.is_a?(User) and current_user == @entity
#      return true
#    elsif @entity.is_a?(Group)
#      return true if action_name == 'show'
#      return true if logged_in? and current_user.member_of?(@entity)
#      return false
#    elsif action_name =~ /add_/
#     return true # TODO: this is the right way to do this
#    end
  end
  
  

end
