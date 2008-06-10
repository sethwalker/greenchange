class MeController < ApplicationController
  helper :network_events

  before_filter :login_required
  #include PathFinder::Options

  def show 
  end
    
=begin
  def dashboard
    redirect_to :action => 'show'
  end

  def files
    @pages = Page.in_network(current_user).allowed(current_user).page_type('asset')
    @assets = @pages.collect {|page| page.data }
  end

  def tasks
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
      included = [:page, {:tasks => :users}] # eager load all we will need to show the tasks.
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
=end
  

end
