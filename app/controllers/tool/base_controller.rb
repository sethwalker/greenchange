# super class controller for all page types

class Tool::BaseController < ApplicationController
  include ToolCreation

  prepend_before_filter :fetch_page_data
  append_before_filter :login_or_public_page_required
  append_before_filter :setup_default_view
  append_after_filter :update_participation
  
  def page_type
    return controller_name.demodulize.downcase.to_sym unless params[:page_type]
    case params[:page_type]
      when 'updates' 
        [:news, :blog]
      when 'media'
        [:image, :video, :audio, :asset]
      when 'involvements'
        [:event, :action_alert]
      when 'tools'
        [:discussion, :rate_many, :ranked_vote, :task_list ]
      else
        params[:page_type]
    end
  end

  def index
    load_context
    @pages = Page.allowed(current_user).page_type( page_type ).by_group( @group ).by_issue( params[:issue_id ]).by_person( @person )
    unless !Dir.glob( "#{RAILS_ROOT}/app/views/tool/#{page_type}/index*").empty?  and  render :action => "index" 
       render :action => '../shared/index'
    end
  end

  # the form to create this type of page
  # can be overridden by the subclasses
  def new 
    @page_class = Page.display_name_to_class(params[:id])
  end

  def create
    @page = create_new_page
    if @page.valid?
      return redirect_to(page_url(@page))
    else
      message :object => @page
      render :template => 'tool/base/new'
    end
  end
  
  def title
    return redirect_to(page_url(@page)) unless request.post?
    @page.title = params[:page][:title]
    @page.name = params[:page][:name].to_s.nameize if params[:page][:name].any?
    if @page.save
      redirect_to page_url(@page)
    else
      message :object => @page
      @page.name = @page.original_name
      render :action => 'show'
    end
  end

  protected

  
  def update_participation
    if logged_in? and @page and params[:action] == 'show'
      current_user.viewed(@page)
    end
  end
  
  def setup_default_view
    @show_posts = (%w(show title).include?params[:action]) # default, only show comment posts for the 'show' action
    @show_reply = @posts.any? # by default, don't show the reply box if there are no posts
    #@sidebar = true
    #@html_title = @page.title if @page
    setup_view # allow subclass to override view
    true
  end
  
  # to be overwritten by subclasses.
  def setup_view
  end
  
  def login_or_public_page_required
    if action_name == 'show' and @page and @page.public?
      true
    else
      return login_required
    end
  end
  
  # this needs to be fleshed out for each action
  def authorized?
    if @page
      #current_user.may?(:admin, @page)
      #current_role.allows? action_name, @page
      @page.allows? current_user, action_name
    else
      true
    end
  end
  
  def fetch_page_data
    return true unless @page or params[:id]
    unless @page
      # typically, @page will be loaded by the dispatch controller. 
      # however, in some cases (like ajax) we bypass the dispatch controller
      # and need to grab the page here.
      @page = Page.find(params[:id])
    end
    return true if request.xhr?
    if logged_in?
      # grab the current user's participation from memory
      @upart = @page.participation_for_user(current_user) if logged_in?
    else
      @upart = nil
    end
    @page.discussion = Discussion.new unless @page.discussion
    
    disc = @page.discussion
    current_page = params[:posts] || disc.last_page #last_page = (posts.count.to_f / per_page.to_f).ceil.to_i
    @posts = disc.posts.paginate(:all, :include => 'ratings', :page => current_page, :per_page => disc.per_page)
    @post = Post.new
    true
  end
      
  def context
    return true if request.xhr?
    @group ||= Group.find_by_id(params[:group_id]) if params[:group_id]
    @person ||= User.find_by_id(params[:user_id]) if params[:user_id]
    @user ||= current_user 
    page_context
    true
  end
  
end
