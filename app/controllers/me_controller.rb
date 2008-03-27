class MeController < ApplicationController

  before_filter :login_required
  before_filter :fetch_user
  #stylesheet 'me'
  #layout 'application'

  def index
    redirect_to :action => 'dashboard'
  end
    
  def search
    if request.post?
      return redirect_to search_me_url(:path => build_filter_path(params[:search]))
    end

    path = (params[:path].dup if params[:path]) || []
    should_be_starred = path.delete('starred')
    should_be_pending = path.delete('pending')
    options = Hash[*path.flatten]
    @pages = current_user.pages.
      starred?(should_be_starred).
      pending?(should_be_pending).
      created_by(options['person']).
      viewable_in_group(options['group'], current_user).
      created_in_month(options['month']).
      created_in_year(options['year']).
      text(options['text']).
      paginate(:page => params[:section])

    if parsed_path.sort_arg?('created_at') or parsed_path.sort_arg?('created_by_login')    
      @columns = [:icon, :title, :group, :created_by, :created_at, :contributors_count]
    else
      @columns = [:icon, :title, :group, :updated_by, :updated_at, :contributors_count]
    end
    full_url = search_me_url + '/' + String(parsed_path)
    handle_rss :title => full_url, :link => full_url,
               :image => avatar_url(:id => @user.avatar_id||0, :size => 'huge')
  end
  
  def dashboard
  end

  def counts
    redirect_to :action => :index and return false unless request.xhr?
    @request_count = current_user.contact_requests_received.pending.count  + current_user.groups_administering.sum {|g| g.membership_requests.pending.count }
    @unread_count = current_user.pages_unread.count
    @pending_count = current_user.pages_pending.count
    render :layout => false
  end

  def page_list
    return false unless request.xhr?
    @pages = Page.in_network(current_user).allowed(current_user).find(:all, :order => "updated_at DESC, group_name ASC", :limit => 40)
    render :layout => false
  end
  
  def files
    @pages = Page.in_network(current_user).allowed(current_user).page_type('asset')
    @assets = @pages.collect {|page| page.data }
  end

  def tasks
    @stylesheet = 'tasks'
    filter = params[:id] || 'my-pending'
    if filter =~ /^all-(.*)/
      completed = $1 == 'completed'
      @pages = Page.in_network(current_user).allowed(current_user).page_type('task')
      @task_lists = @pages.collect{|page|page.data}
      @show_user = 'all'
      @show_status = completed ? 'completed' : 'pending'
    elsif filter =~ /^group-(.*)/
      # show tasks from a particular group
      groupid = $1
      @group = Group.find groupid
      @pages = @group.pages.page_type('task').allowed(current_user)
      @task_lists = @pages.collect{|page|page.data}
      @show_user = 'all'
      @show_status = 'pending'
    elsif filter =~ /^my-(.*)/
      # show my completed or pending tasks
      completed = $1 == 'completed'
      included = [:pages, {:tasks => :users}] # eager load all we will need to show the tasks.
      conditions = ["users.id = ? AND tasks.completed_at #{(completed ? 'IS NOT NULL' : 'IS NULL')}", current_user.id ]
      @task_lists = Task::TaskList.find(:all, :conditions => conditions, :include => included)
      @show_user = current_user
      @show_status = completed ? 'completed' : 'pending'
    end
  end
 
  def edit   
    if request.post? 
      if @user.update_attributes(params[:user])
        redirect_to :action => 'edit'
        flash[:notice] = 'Your profile was successfully updated.'
      else
        message :object => @user
      end
    end
  end
  
  protected

  # it is impossible to see anyone else's me page,
  # so no authorization is needed.
  def authorized?
    return true
  end
  
  def fetch_user
    @user = current_user
  end
  

#  def context
#    me_context('large')
#    unless ['show','index'].include?(params[:action])
#      # url_for is used here instead of me_url so we can include the *path in the link
#      # (it might be a bug in me_url that this is not included, or it might be a bug in url_for
#      # that it is. regardless, we want it.)
#      add_context params[:action], url_for(:controller => 'me', :action => params[:action])
#    end
#  end
  
end

