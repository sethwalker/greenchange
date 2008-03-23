=begin

PersonContoller
================================

A controller which handles a single user. For processing collections of users,
see PeopleController.

=end

class PersonController < ApplicationController
  helper ProfileHelper
  layout 'application'
  
  def initialize(options={})
    super()
    @person = options[:user]   # the user context, if any
  end
  
  def show
    load_context
    params[:path] ||= "descending/updated_at"
    search
  end

  def search
    @pages = @person.pages.allowed(current_user).paginate(:page => params[:section])
    @columns = [:icon, :title, :group, :updated_by, :updated_at, :contributors]
  end

  def tasks
    @stylesheet = 'tasks'
    @pages = Page.in_network(@person).allowed(current_user).page_type(:task_list).find(:all, :conditions => ["user_participations.resolved = ?", false])
    @task_lists = @pages.collect{|p|p.data}
  end
    
  protected
  
  def context
    person_context
    unless ['show'].include? params[:action]
      add_context params[:action], people_url(:action => params[:action], :id => @person )
    end
  end
  
  prepend_before_filter :fetch_user
  def fetch_user 
    @person ||= User.find_by_login params[:id] if params[:id]
    true
  end
  
end
