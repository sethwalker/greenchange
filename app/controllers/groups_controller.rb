require 'svg/svg' 

class GroupsController < ApplicationController
  include GroupsHelper
  helper 'groups_content'
  helper :profile

  
  stylesheet 'groups'
  
  prepend_before_filter :find_group, :except => ['list','new','create','index']
  
  before_filter :login_required,
    :except => [:list, :index, :show, :search, :archive, :tags]
  before_filter :authorized_to_view?, :only => :archive
    
  verify :method => :post,
    :only => [:create, :update, :destroy]

  def initialize(options={})
    super()
    @group = options[:group] # the group context, if any
  end  
  
  def index
    list
    render :action => 'list'
  end

  def list
    @groups = Group.find :all, :conditions => 'type IS NULL'
    set_banner "groups/banner_search", Style.new(:background_color => "#1B5790", :color => "#eef")
  end

  def show
    return render(:template => 'groups/show_nothing') unless @group.allows?(current_user, :view)
    @pages = @group.pages.allowed(current_user, :view).find(:all, :order => 'pages.updated_at DESC', :limit => 20)
    @profile = @group.profile
    @wiki = @group.page
  end

  def new
  end

  # login required
  def create
    raise 'must call new' if request.get?

    @parent = Group.find(params[:parent_id]) if params[:parent_id]
    unless current_user.superuser?
      if @parent and not current_user.member_of?(@parent)
        message( :error => 'you do not have permission to do that'.t, :later => true )
        redirect_to url_for_group(@parent)
      end
    end

    if @parent
      @group = Committee.new(params[:group])
      @group.parent = @parent
    else
      @group = Group.new(params[:group])
    end

    unless @group.save
      message :object => @group
      render :action => :new and return
    end

    message :success => 'Group was successfully created.'.t

    # group creator is its default administrator (TODO: is this assumption true???)
    @group.memberships.create :user => current_user, :group => @group, :role => 'administrator'
    redirect_to url_for_group(@group)
  end

  # login required
  def edit
    if request.post? 
      if @group.update_attributes(params[:group])
        redirect_to :action => 'edit', :id => @group
        message :success => 'Group was successfully updated.'
      else
        message :object => @group
      end
    end
  end
    
  # login required
  # post required
  def update
    @group.update_attributes(params[:group])
    redirect_to :action => 'show', :id => @group
  end
  
  # login required
  # post required
  def destroy
    if @group.users.uniq.size > 1 or @group.users.first != current_user
      message :error => 'You can only delete a group if you are the last member'
      redirect_to :action => 'show', :id => @group
    else
      @group.destroy
      if @group.parent
        redirect_to url_for_group(@group.parent)
      else
        redirect_to :action => 'list'
      end
    end
  end  
     
  def media
  	@pages = @group.pages  
  end

  def archive
    @months = @group.months_with_pages_viewable_by_user(current_user)
    
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
      return redirect_to(groups_url(:id => @group, :action => 'search') + 
        build_filter_path(params[:search]))
    end

    path = (params[:path].dup if params[:path]) || []
    should_be_starred = path.delete('starred')
    should_be_pending = path.delete('pending')
    options = Hash[*path.flatten]

    @pages = @group.pages.allowed(current_user).
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

    handle_rss :title => @group.name, :description => @group.summary,
               :link => url_for_group(@group),
               :image => avatar_url(:id => @group.avatar_id||0, :size => 'huge')
  end
  
  def tags
    @pages = @group.pages.allowed(current_user).tagged(params[:path]).paginate(:page => params[:section])
  end

  def tasks
    @stylesheet = 'tasks'
    @task_lists = @group.pages.allowed(current_user, :view).page_type('Tool::TaskList').find(:all, :conditions => ["pages.resolved = ?", false]).collect{|page| page.data}
  end

  def visualize
    unless logged_in? and current_user.member_of?(@group)
      message( :error => 'you do not have permission to do that', :later => true )
      redirect_to url_for_group(@group)
    end

    # return xhtml so that svg content is rendered correctly --- only works for firefox (?)    
    response.headers['Content-Type'] = 'application/xhtml+xml'       
  end

  protected
  
  def context
    group_context
    unless ['show','index','list'].include? params[:action]
      add_context params[:action], url_for(:controller=>'groups', :action => params[:action], :id => @group, :path => params[:path])
      # url_for is used here to capture the path
    end
  end
  
  def find_group
    @group = Group.get_by_name params[:id].sub(' ','+') if params[:id]
  end

  #this is a terrible method, but this is a better place than find_group
  def authorized_to_view?
    unless @group and (@group.publicly_visible_group or @group.allows?(current_user, :view)) ##committees need to be handled better
      render :template => 'groups/show_nothing'
      return false
    end
    true
  end
  
  def authorized?
    non_members_post_allowed = %w(archive search tags tasks create)
    non_members_get_allowed = %w(new show members) + non_members_post_allowed

    if request.get? and non_members_get_allowed.include? params[:action]
      return true
    elsif request.post? and non_members_post_allowed.include? params[:action]
      return true
    else
      return(logged_in? and @group.allows?(current_user, params[:action]))
    end
  end    
  
  def edit_profile
    @profile = @group.profiles.public
    @profile.save_from_params(params[:profile]) if request.post?
  end
end
