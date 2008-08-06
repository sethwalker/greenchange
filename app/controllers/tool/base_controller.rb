# super class controller for all page types

class Tool::BaseController < ApplicationController
  include ToolCreation

  #prepend_before_filter :fetch_page_data
  #append_before_filter :setup_default_view
  before_filter :login_required, :except => [ :show, :index, :landing ]
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

  def show
    @page = page_class.find( params[:id] )
    raise PermissionDenied unless @page.allows? current_user, :view
  end

  def index
    if params[:query]
      @pages = page_class.search(params[:query], :with => { :public => 1 })
    else
      @pages = Page.allowed(current_user).page_type( page_type ).by_group( @group ).by_issue( params[:issue_id ]).by_person( ( @me || @person ) ).paginate :all, :page => params[:page], :order => 'created_at DESC'
    end
    respond_to do |format|
      format.html do
        unless !Dir.glob( "#{RAILS_ROOT}/app/views/tool/#{( params[:page_type] || page_type )}/index*").empty?  and  render :action => "index" 
           render :action => '../shared/index'
        end
      end
      format.rss do
        options = {
          :title => [ 'Crabgrass Content', (scoped_by_context? ? scoped_by_context?.display_name : nil ), ( params[:page_type] || page_type ).to_s.titleize ].compact.join( ' - ' ), 
          :link => url_for(:action => 'index', :controller => controller_name, :belongs_to => scoped_by_context? ),
          :image => icon_path_for( scoped_by_context? ),
          :items => @pages
        }
        render :partial => 'pages/rss', :locals => options
      end
    end
      
    
  end

  # the form to create this type of page
  # can be overridden by the subclasses
  #def new 
  #  @page_class ||= Tool.const_get(controller_name.classify)
  #  @page = @page_class.new
  #  unless !Dir.glob( "#{RAILS_ROOT}/app/views/tool/#{page_type}/new*").empty?  and  render :action => "new" 
  #     render :action => "../base/new"
  #  end
  #end

  def new 
    @page = page_class.new :group_id => ( @group ? @group.id : nil ), :public => true, :public_participate => true
    @page.build_data if @page.respond_to? :build_data
  end

  def page_class
    klass = Tool.const_get(controller_name.classify)
    klass = Tool::TextDoc if ( klass == Wiki ) #|| klass == Tool::Wiki)
    @page_class ||= ( klass.ancestors.include?(Page) ? klass : Page )
  rescue
    Page
  end

  def create
#    new hotness -----------------------------------------------|
    page_data = params[:page].delete(:page_data )
    @page = page_class.new params[:page]
    @page.build_data setup_data(page_data) if @page.respond_to? :build_data
    @page.created_by = current_user

    #raise @page.data.inspect unless @page.data.save
    #@page.data.save!
    if @page.save
      flash[:notice] = 'Your content has been added to the network.  Thanks.  Do it again soon.'
      redirect_to tool_page_path(@page)
    else
      render :action => 'new'
    end

  end
#
#  def create
#    @page = page_class.new params[:page]
#    @data = @page.build_data params[:data] if params[:data]
#    if @page.save
#      # move to model
#      #add_participants!(page, params)
#      # end move to model
#      return redirect_to(page_url(@page))
#    else
#      message :object => @page
#      render :template => 'tool/base/new'
#    end
#  end
  def edit
    @page = page_class.find( params[:id] )
    raise PermissionDenied unless current_user.may? :edit, @page
    @page.data.lock( Time.now, current_user )  if @page.data.is_a? Wiki
  end
  
    #if @page.data.is_a?( Wiki ) 
    #  if params[:cancel] && @page.data.editable_by?( current_user )
    #    @page.data.unlock 
    #    redirect_to tool_page_url(@page) and return
    #  end
    #  @page.data.updater = current_user
    #end

  def update

    @page = page_class.find( params[:id] )
    raise PermissionDenied unless current_user.may? :edit, @page
    page_data = params[:page].delete(:page_data ) if params[:page]
    @page.attributes = params[:page]
    @page.page_data = setup_data(page_data)
      
    @page.updated_by = current_user
    if @page.save
      flash[:notice] = 'This page has been updated.'
      redirect_to tool_page_path(@page)
    else
      render :action => 'edit'
    end
  end

  def destroy
    page = Page.find params[:id]
    current_user.may! :admin, page
    page.destroy
    flash[:notice] = "Deleted \"#{page.display_name}\""
    redirect_to me_pages_path
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
      @page.allows? current_user, action_name.to_sym
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
      
  def setup_data(page_data)
    #stub returns self
    page_data 
  end
end
