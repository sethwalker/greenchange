class ApplicationController < ActionController::Base
  Tag # need this to reload has_many_polymorphs in development mode

  #this enables exception_logger plugin
  include ExceptionLoggable

  #this is the system authentication module
  include AuthenticatedSystem

  #CRUFT this is role-based permissions, not used so much
  include AuthorizedSystem

  #this deals with polymorphic paths for pages and Tool:: instances
  include PageUrlHelper

  #CRUFT this is in controller to support rss w/options -- replace w/builder
  include ContextHelper
  
  #this produces icon paths
  include IconHelper

  rescue_from PermissionDenied, :with => :access_denied
  rescue_from ActiveRecord::RecordNotFound, :with => :redirect_to_index
  # don't allow passwords in the log file.
  filter_parameter_logging "password", "password_confirmation"
  
  #before_filter :pre_clean
  before_filter :load_context
  around_filter :set_timezone
  session :session_secure => true if Crabgrass::Config.https_only
  protect_from_forgery

  protected
  
  #sends the user to the problem report page
  def rescue_action_in_public(exception)
    status = response_code_for_rescue(exception)
    @logged_exception = log_exception(exception) if status != :not_found
    respond_to do |format|
      format.html do
        render :file => 'shared/problem_report', :use_full_path => true, :layout => true, :status => status, :locals => { :problem => @logged_exception }
      end
      format.rss { render :status => status }
    end
  end


  # a layer to obscure the native flash api
  def message(opts)    
    if opts[:success]
      flash[:notice] = opts[:success]
    elsif opts[:error]
      if opts[:later]
        flash[:error] = opts[:error]
      else
        flash.now[:error] = opts[:error]
      end
    elsif opts[:object]
      object = opts[:object]
      unless object.errors.empty?
        flash.now[:error] = "Changes could not be saved."
        flash.now[:text] ||= ""
        flash.now[:text] += "<p>#{'There are problems with the following fields'}:</p>"
        flash.now[:text] += "<ul>" + object.errors.full_messages.collect { |msg| "<li>#{msg}</li>"}.join(' ') + "</ul>"
        flash.now[:errors] = object.errors
      end
    end
  end
  
  private
  
  # clears class attributes ( for use in production )
  # this may not be needed since no models currently use User.current
  #def pre_clean
  #  User.current = nil
  #end

  # sets timezone to match the registered preference of the current user
  def set_timezone
    TzTime.zone = TimeZone[DEFAULT_TZ]
    TzTime.zone = TimeZone[current_user.time_zone] if logged_in? && current_user.time_zone 
    yield
    TzTime.reset!
  end

  # send users to list page when rescuing from RecordNotFound
  def redirect_to_index(exception)
    if action_name == 'show'
      flash[:error] = "Couldn't find the item you asked for."
      redirect_to :action => 'index'
    else
      raise exception
    end
  end

  # determines if the current controller is scoped by other items and sets an instance variable
  # can set the following items : @group, @issue, @tag, @person, @event, @me, @user
  def load_context
    @group ||= Group.find_by_name params[:group_id] if params[:group_id]
    @issue ||= Issue.find_by_name params[:issue_id].gsub( '-', ' ') if params[:issue_id]
    @tag ||=   Tag.find_by_name  params[:tag_id]    if params[:tag_id]
    @person ||= User.enabled.find_by_login params[:person_id] if params[:person_id]
    @event ||= Tool::Event.find params[:event_id] if params[:event_id]
    if logged_in?
      @me ||= current_user if request.request_uri =~ /^\/(me|$)/ 
      @user ||= current_user 
    end
    true
  end

  def group_admin_required
    current_user.may!( :admin, @group ) if @group 
    true
  end


    
end
