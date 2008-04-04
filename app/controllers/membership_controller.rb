=begin
Membership Controller
---------------------

All the relationships between users and groups are managed by this controller,
including join requests.

=end

class MembershipController < ApplicationController
  #layout 'groups'
  stylesheet 'groups'
  #helper 'application'
    
  before_filter :login_required#, :except => ['list']
  #prepend_before_filter :fetch_group, :except => [:approve, :reject, :view_request]

  #verify :method => :post, :only => [:approve, :reject]

  ###### PUBLIC ACTIONS #########################################################
  
  def list
    
  end
  
  ###### USER ACTIONS #########################################################
  
  # request to join this group
  def join
  end
  def new
    @membership_request = MembershipRequest.new :group => @group, :user => current_user 
  end

  def create
    return create_as_admin if @group.users.empty?
    @membership_request = MembershipRequest.find_or_initialize_by_user_id_and_group_id current_user.id, @group.id
    @membership_request.attributes = params[:membership_request]
    if @membership_request.save
      flash[:notice] = 'Your request to join this group has been sent.'
      redirect_to group_url(@group) and return
    else
      render :action => 'new'
    end
  end

  ###### MEMBER ACTIONS #########################################################
  
  # leave this group
  def leave
  end

  def destroy
    current_user.groups.delete(@group)
    message :success => 'You have been removed from %s' / @group.name
    redirect_to group_url(@group)
  end
  
  ###### ADMIN ACTIONS #########################################################

  def update
    if @group.committee? and params[:group]
      new_ids = params[:group][:user_ids]
      @group.memberships.each do |m|  
        m.destroy if m.user.member_of?(@group.parent) and not new_ids.include?(m.user_id.to_s)
      end
      new_ids.each do |id|
        next unless id.any?
        u = User.find(id)
        @group.memberships.create(:user => u) if u.member_of?(@group.parent) and not u.direct_member_of?(@group)
      end
      message :success => 'member list updated'
      redirect_to :action => 'list', :id => @group
    end
  end

  def invite
    return unless request.post? # form on get
    
    wrong = []
    sent = []
    params[:users].split(/\s*[,\s]\s*/).each do |login|
      next if login.empty?
      if user = User.find_by_login(login)
        req = MembershipRequest.find_or_initialize_by_user_id_and_group_id user.id, @group.id
        req.approved_by = current_user
        req.save
        sent << login
      else
        wrong << login
      end
    end
    if wrong.any?
      message :later => true, :error => "These invites could not be sent because the user names don't exist: " + wrong.join(', ')
    elsif sent.any?
      message :success => 'Invites sent: ' + sent.join(', ')
    end
    redirect_to :action => 'list', :id => @group
  end
  
  def requests
    @requests = @group.membership_requests.paginate(:page => params[:section],
                                                    :order => "created_at DESC")
  end
  
  def view_request
    @membership_request = MembershipRequest.find(params[:id])
  end

  def approve
    @membership_request = MembershipRequest.find(params[:id])
    raise PermissionDenied unless @membership_request.group.allows?(current_user, :admin)
    @membership_request.approved_by = current_user
    if @membership_request.approve!
      respond_to do |format|
        format.html do
          flash[:notice] = "Request Approved, Membership Granted"
          redirect_to group_url(@group)
        end
        format.xml  { render :xml  => @group.membership_for( @membership_request.user) }
        format.json { render :json => @group.membership_for( @membership_request.user) }
      end
    else
      respond_to do |format|
        format.html do
          render :action => 'index'
        end
        format.json { render :json => @membership_request, :status => :unprocessable_entity }
        format.xml  { render :xml  => @membership_request, :status => :unprocessable_entity }
      end
    end
  end

  def reject
    @membership_request = MembershipRequest.find(params[:id])
    raise PermissionDenied unless @membership_request.group.allows?(current_user, :admin)
    if @membership_request.reject!
      respond_to do |format|
        format.html do
          flash[:notice] = 'Request rejected'
          redirect_to group_url(@group)
        end
        format.xml  { head :ok }
        format.json { head :ok }
      end
    else
      respond_to do |format|
        format.html do
          render :action => 'index'
        end
        format.json { render :json => @membership_request, :status => :unprocessable_entity }
        format.xml  { render :xml  => @membership_request, :status => :unprocessable_entity }
      end
    end
  end

  protected
    
  def context
    group_context
    add_context 'membership', url_for(:controller=>'membership', :action => 'list', :id => @group)
  end
  
#  def fetch_group
#    @group = Group.get_by_name params[:group_id].sub(' ','+') if params[:group_id]
#    if @group
#      @group_type = @group.class.to_s.downcase
#      return true
#    else
#      render :action => 'not_found'
#      return false
#    end
#  end
  
  def authorized?
    raise ActiveRecord::RecordNotFound unless @group
    non_members_post_allowed = %w(create)
    non_members_get_allowed = %w(list join new) + non_members_post_allowed
    if request.get? and non_members_get_allowed.include? params[:action]
      return true
    elsif request.post? and non_members_post_allowed.include? params[:action]
      return true
    elsif %w[ approve deny index ].include?(params[:action] )
      return current_user.may?( :admin, @group )
    else
      return(logged_in? and current_user.member_of? @group)
    end
  end
  
  def create_as_admin
    # if the group has no users, then let the first person join.

    # TODO: how could this happen if users are auto-added to groups they create?
    # just in case, first user to join a group becomes its admin
    @group.memberships.create :user => current_user, :group => @group, :role => 'administrator'

    flash[:notice] = 'You are the first person in this group'
    redirect_to group_url( @group) and return
  end

end
