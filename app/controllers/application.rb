class ApplicationController < ActionController::Base
  Tag # need this to reload has_many_polymorphs in development mode

  include AuthenticatedSystem
  include AuthorizedSystem
  include PageUrlHelper
  include ContextHelper
  #include TimeHelper
  #

  include PathFinder::Options
      
  rescue_from PermissionDenied, :with => :access_denied
  # don't allow passwords in the log file.
  filter_parameter_logging "password"
  
  before_filter :pre_clean
  before_filter :load_context
  #before_filter :assume_role, :except => :login  # after context
  around_filter :set_timezone
  session :session_secure => true if Crabgrass::Config.https_only

  protected
  
  # let controllers set a custom stylesheet in their class definition
  def self.stylesheet(cssfile=nil)
    write_inheritable_attribute "stylesheet", cssfile if cssfile
    read_inheritable_attribute "stylesheet"
  end
  
  def get_unobtrusive_javascript
    @js_behaviours.to_s
  end
  
  def handle_rss(locals)
    if params[:path].any? and 
        (params[:path].include? 'rss' or params[:path].include? '.rss')
      response.headers['Content-Type'] = 'application/rss+xml'   
      render :partial => '/pages/rss', :locals => locals
    end
  end

  def rescue_action_in_public(*args)
    @exception = args.shift
    render :file => 'shared/problem_report', :use_full_path => true, :layout => true, :status => :not_found 
  end


  # a one stop shopping function for flash messages
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
  
  # some helpers we include in controllers. this allows us to 
  # grab the controller that will work in a view context and a
  # controller context.
  def controller
    self
  end 
  
  private
  
  def pre_clean
    User.current = nil
  end

  def set_timezone
    TzTime.zone = TimeZone[DEFAULT_TZ]
    TzTime.zone = TimeZone[current_user.time_zone] if logged_in? && current_user.time_zone 
    yield
    TzTime.reset!
  end

  # CONTEXT USAGE
  def load_context
    @group ||= Group.find_by_name params[:group_id] if params[:group_id]
    @issue ||= Issue.find_by_name params[:issue_id].gsub( '-', ' ') if params[:issue_id]
    @tag ||=   Tag.find_by_name  params[:tag_id]    if params[:tag_id]
    @person ||= User.find_by_login params[:person_id] if params[:person_id]
    if logged_in?
      @me ||= current_user if request.request_uri =~ /^\/me/ 
      @user ||= current_user 
    end
  end


    
end
