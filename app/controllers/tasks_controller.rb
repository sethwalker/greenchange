class TasksController < ApplicationController
  before_filter :load_task_context

  def new
    @task = @page.data.tasks.build
  end

  def create
    @task = @page.data.tasks.build params[:task]
    respond_to do |format|
      if @task.save
        format.html do
          flash[:notice] = "New task created"
          redirect_to task_path(@page)
        end
        format.json { render :json => @task, :status => :created, :location => task_task_path(@page, @task) }
        format.xml  { render :xml  => @task, :status => :created, :location => task_task_path(@page, @task) }
        
      else
        format.html { render :action => 'new' }
        format.xml  { render :xml  => @task.errors, :status => :unprocessable_entity }
        format.json { render :json => @task.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @task = @page.data.tasks.find params[:id]
    respond_to do |format|
      if @task.update_attributes(params[:task])
        format.html do 
          flash[:notice] = "Item was successfully updated."
          redirect_to( :controller => 'tasks', :id => @task.id ) 
        end
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml  => @task.errors, :status => :unprocessable_entity }
        format.json { render :json => @task.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @task = @page.data.tasks.find params[:id]
  end
  def mark_complete
    @task = @page.data.tasks.find params[:id]
    @task.update_attribute :completed, true
    @task.move_to_bottom
    redirect_to task_url(@page) unless request.xhr?
  end
  def mark_pending
    @task = @page.data.tasks.find params[:id]
    @task.update_attribute :completed, false
    @task.move_to_bottom
    redirect_to task_url(@page) unless request.xhr?
  end

  def destroy
    @task = @page.data.tasks.find params[:id]
    @task.destroy
    respond_to do |format|
      format.html do
        flash[:notice] = "Task was deleted from #{@page.title}"
        redirect_to( :controller => 'collectings', :action => 'index' )
      end 
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end

  def load_task_context
    @page = Tool::TaskList.find params[:task_id] if params[:task_id]
    @page ||= Tool::TaskList.find params[:page_id] if params[:page_id]
  end
end
