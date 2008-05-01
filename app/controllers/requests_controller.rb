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
  #layout 'me'

  def index
    @my_contact_requests_sent = current_user.contact_requests_sent.pending.find(:all, :order => "created_at DESC", :limit => 20)
    @my_contact_requests_received = current_user.contact_requests_received.pending.find(:all, :order => "created_at DESC", :limit => 20)

    @my_membership_requests = current_user.membership_requests.pending.find(:all, :order => "created_at DESC", :limit => 20)

    @my_groups_membership_requests = MembershipRequest.pending.find(:all, :conditions => ["group_id IN (?)", current_user.groups_administering], :order => "created_at DESC", :limit => 20)
  end

  def mine
    @requests = current_user.contact_requests_sent.pending.paginate(:page => params[:section], :order => "created_at DESC")
    render :action => 'more'
  end
  
  def contacts
    @requests = current_user.contact_requests_received.pending.paginate(:page => params[:section], :order => "created_at DESC")
    render :action => 'more'
  end

  def memberships
    @requests = MembershipRequest.pending.paginate(:all, :page => params[:section], :conditions => ["group_id IN (?)", current_user.groups_administering], :order => "created_at DESC")
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
  
#  def context
#    me_context('small')
#    add_context 'requests', url_for(:controller => 'requests', :action => 'index')
#    add_context params[:action], url_for(:controller => 'requests') unless params[:action] == 'index'
#  end
  
end

