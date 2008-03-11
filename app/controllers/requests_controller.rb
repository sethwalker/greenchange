#
# my requests:
#  my contact requests
#  my membership requests
#
# contact requests:
#   from other to me
#
# membership requests:
#   from other to groups i am admin of
#

class RequestsController < ApplicationController

  before_filter :login_required
  before_filter :fetch_user
  layout 'me'

  def index
    @my_pages = current_user.pages_created.find(:all, :conditions => ["pages.flow IN (?)", [FLOW[:contacts], FLOW[:membership]]], :order => "pages.created_at DESC", :limit => 20)
    @my_columns = [:title, :created_at, :contributors_count]

    @contact_pages = current_user.pages.page_type('Tool::Request').find(:all, :conditions => ["pages.flow = ? AND pages.created_by_id <> ?", FLOW[:contacts], current_user.id], :order => "pages.created_at DESC", :limit => 20)
    @contact_columns = [:title, :discuss, :created_by, :created_at, :contributors_count]

    @membership_pages = current_user.pages.page_type('Tool::Request').find(:all, :conditions => ["pages.flow = ? AND pages.created_by_id <> ?", FLOW[:membership], current_user.id], :order => "pages.created_at DESC", :limit => 20)
    @membership_columns = [:title, :group, :discuss, :created_by, :created_at, :contributors_count]
  end

  def mine
    @pages = current_user.pages_created.paginate(:page => params[:section], :conditions => ["pages.flow IN (?)", [FLOW[:contacts], FLOW[:membership]]], :order => "pages.created_at DESC")
    @columns = [:title, :created_at, :contributors_count]
    render :action => 'more'
  end
  
  def contacts
    @pages = current_user.pages.page_type('Tool::Request').paginate(:page => params[:section], :conditions => ["pages.flow = ? AND pages.created_by_id <> ?", FLOW[:contacts], current_user.id], :order => "pages.created_at DESC")
    @columns = [:title, :discuss, :created_by, :created_at, :contributors_count]
    render :action => 'more'
  end

  def memberships
    @pages = current_user.pages.page_type('Tool::Request').paginate(:page => params[:section], :conditions => ["pages.flow = ? AND pages.created_by_id <> ?", FLOW[:membership], current_user.id], :order => "pages.created_at DESC")
    @columns = [:title, :group, :discuss, :created_by, :created_at, :contributors_count]
    render :action => 'more'
  end

  def more
  end
  
  protected
  
  def authorized?
    return true # current_user always authorized for me
  end

  def fetch_user
    @user = current_user
  end
  
  def context
    me_context('small')
    add_context 'requests', url_for(:controller => 'requests', :action => 'index')
    add_context params[:action], url_for(:controller => 'requests') unless params[:action] == 'index'
  end
  
end

