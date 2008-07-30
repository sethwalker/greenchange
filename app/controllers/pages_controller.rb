=begin

PagesController
---------------------------------

This is a controller for managing abstract pages. The display and editing of
a particular page type (aka tool) are handled by controllers in controllers/tool.

When should an action be in this controller or in Tool::Base?
The general rule is this:

   If the action can go in PagesController, then do so.

This means that only stuff specific to a tool should go in the
tool controllers.

For example, there are two create() actions, one in PagesControllers
and one in Tool::Base. The one in PagesController handles the first
step where you choose a page type. The one in Tool::Base handles the
next step where you enter in data. This step is handled by Tool::Base
so that each tool can define their own method of creation.

=end

class PagesController < ApplicationController

  helper Tool::BaseHelper
  
  before_filter :login_required, :except => [:search, :index]
  prepend_before_filter :fetch_page
  include IconResource

  def show
    redirect_to tool_page_path(@page) if @page.type
    #short_name = @page.class.to_s.demodulize.underscore.downcase
    #@wiki = @page.data
    #render :action => "../tool/#{short_name}/show" or raise NameError
  end

  ##############################################################
  ## PUBLIC ACTIONS
  
  def index
    load_context
    if params[:query]
      @pages = Page.search(params[:query], :with => { :public => 1 })
    else
      @pages = Page.allowed(current_user).by_group( @group ).by_issue( params[:issue_id ]).by_person( ( @me || @person ) ).by_tag( @tag ).paginate :all, :page => params[:page], :per_page => 100, :order => 'updated_at DESC'
    end
    respond_to do |format|
      format.html {}
      format.rss do
        options = {
          :title => [ 'Crabgrass Content', (scoped_by_context? ? scoped_by_context?.display_name : nil ) ].compact.join( ' - ' ), 
          :link => url_for(:action => 'index', :controller => 'pages', :belongs_to => scoped_by_context? ),
          :image => icon_path_for( scoped_by_context? ),
          :items => @pages
          }
          render :partial => 'rss', :locals => options
      end
    end
  end
  
#  def search
#    unless @pages
#      if logged_in?
#        options = options_for_me
#      else
#        options = options_for_public_pages
#      end
#      @pages, @page_sections = Page.find_and_paginate_by_path(params[:path], options)
#    end
#  end

  # a simple form to allow the user to select which type of page
  # they want to create. the actual create form is handled by
  # Tool::BaseController (or overridden by the particular tool). 
  def new
  end
  alias :create :new
     
  def tag
    return unless request.xhr?
    @page.tag_with(params[:tag_list])
    @page.save
  rescue Tag::Error => @error
  ensure
    render :partial => "pages/tags"
  end
    
#  # for quickly creating a wiki
#  def create_wiki
#    group = Group.get_by_name(params[:group])
#    if !logged_in?
#      message :error => 'You must first login.'
#    elsif group.nil?
#      message :error => 'Group does not exist.'
#    elsif !current_user.member_of?(group)
#      message :error => "You don't have permission to create a page for that group"
#    else
#      page = Page.make :wiki, {:user => current_user, :group => group, :name => params[:name]}
#      page.save
#      redirect_to page_url(page)
#      return
#    end
#    render :text => '', :layout => 'application'
#  end


  # send an announcement to users about this page.
  # in other words, send to their inbox.
  # requires: login, view access
  def notify
    @errors = []; @infos = []
    params[:to].split(/\s+/).each do |name|
      next unless name.any?
      entity = Group.get_by_name(name) || User.find_by_login(name)
      if entity.nil?
        @errors << "'%s' is not the name of a group or a person." / name
        next
      end
      if @page.public?
        unless current_user.may_pester?(entity)
          @errors << "%s is not allowed to notify %s.".t % [current_user.login, entity.name]
          next
        end
      else
        unless entity.may?(:view, @page)
          @errors << "%s is not allowed to view this page." / entity.name
          next
        end
      end
      notice = params[:message] ? {:user_login => current_user.login, :message => params[:message], :time => Time.now} : nil
      if entity.instance_of? Group
        @page.add(entity.users - [current_user], :notice => notice) if entity.users.any?
      elsif entity.instance_of? User
        @page.add(entity, :notice => notice)
      end
      @infos << name
    end
  end

  def access
    if request.post?
      if params[:remove_group]
        @page.remove(Group.find_by_id(params[:remove_group]))
      elsif params[:remove_user]
        @page.remove(User.find_by_id(params[:remove_user]))
      # maybe we shouldn't allow removal of last entity (?) -- now handled in view -af
      elsif params[:add_name]
        access = params[:access] || :admin
        if group = Group.get_by_name(params[:add_name])
          if current_user.may_pester? group
            @page.add group, :access => access
          else
            message :error => 'you do not have permission to do that'
          end
        elsif user = User.find_by_login(params[:add_name])
          if current_user.may_pester? user
            @page.remove user
            @page.add user, :access => access
          else
            message :error => 'you do not have permission to do that'
          end
        else
          message :error => 'group or user not found'
        end
      end
      @page.save
    end
  end

  def archive
    #@months = @group.months_with_pages_viewable_by_user(current_user)
    
    unless @months.empty?
      @year = params[:path] ? params[:path][0] : @months.last['year']
      @month = params[:path] ? params[:path][1] : @months.last['month']

      @pages = @group.pages.
        allowed(current_user).
        created_in_year(@year).
        created_in_month(@month).
        paginate(:all, 
                 :order => 'updated_at DESC', 
                 :page => params[:page])
    end
  end

  def search
    if request.post?
      return redirect_to(search_pages_path + 
        build_filter_path(params[:search]))
    end

    path = (params[:path].dup if params[:path]) || []
    should_be_starred = path.delete('starred')
    should_be_pending = path.delete('pending')
    options = Hash[*path.flatten]

    @pages = Page.allowed(current_user).
      starred?(should_be_starred).
      pending?(should_be_pending).
      page_type(options['type']).
      created_by(options['person']).
      created_in_month(options['month']).
      created_in_year(options['year']).
      text(options['text'])

    if parsed_path.sort_arg?('created_at') or parsed_path.sort_arg?('created_by_login')    
      @columns = [:icon, :title, :created_by, :created_at, :contributors_count]
    else
      @columns = [:icon, :title, :updated_by, :updated_at, :contributors_count]
    end

    respond_to do |format|
      format.html {}
      format.rss do
        options = {
          :title => "Search pages",
          :description => '',
          :link => pages_path
        }
        render :partial => 'pages/rss', :locals => options
      end
    end
  end
  def participation
    
  end
 
  def new_media
  end
  
  def new_action
  end
  
  def new_tool
  end
  
  def new_post 
	end 
	
  def history
  
  end

  ##############################################
  ## page participation modifications
  
  def remove_from_my_pages
    @upart.destroy
    redirect_to me_url
  end
  
  def add_to_my_pages
    @page.add(current_user)
    redirect_to page_url(@page)
  end
  
  def make_resolved
    @upart.resolved = true
    @upart.save
    redirect_to page_url(@page)
  end
  
  def make_unresolved
    @upart.resolved = false
    @upart.save
    redirect_to page_url(@page)
  end  
  
  def add_star
    @upart.star = true
    @upart.save
    redirect_to page_url(@page)
  end
  
  def remove_star
    @upart.star = false
    @upart.save
    redirect_to page_url(@page)
  end  
    
  def destroy
    return unless request.post?
    #url = from_url(@page)
    @page.data.destroy if @page.data # can this be in page?
    @page.destroy
    redirect_to me_url
  end


  protected
  
  def authorized?
    # see BaseController::authorized?
    if @page
      return current_user.may?(:view, @page)
    else
      return true
    end
  end

  def fetch_page
    @page = Page.find_by_id(params[:id]) if params[:id]
    @upart = (@page.participation_for_user(current_user) if logged_in? and @page)
    true
  end
  
end
