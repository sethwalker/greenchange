=begin
Memberships Controller
---------------------

All the relationships between users and groups are managed by this controller,
including join requests.

=end

class MembershipsController < ApplicationController
    
  before_filter :login_required
  before_filter :group_admin_required, :only => [ 'index', 'promote' ]
  before_filter :find_group

  ###### ADMIN ACTIONS #########################################################
  
  def index
     
  end
  
  ###### USER ACTIONS #########################################################
  
  def new
    return create_as_admin if @group.users.empty?
    redirect_to new_group_join_request_path(@group)
    #return if request_already_exists?
    #@membership_request = MembershipRequest.new :user => current_user, :group => @group

  end
  
  ###### MEMBER ACTIONS #########################################################
  

  def destroy
    @membership = Membership.find params[:id]
    raise PermissionDenied unless @membership.user == current_user or current_user.may? :admin, @group
    @membership.destroy
    flash[:notice] = "#{@membership.user.display_name} is no longer a member of #{@group.name}"
    if current_user == @membership.user
      redirect_to me_groups_path
    else
      redirect_to group_memberships_path(@group)
    end
  end
  
  ###### ADMIN ACTIONS #########################################################

  def promote
    @membership = Membership.find params[:id]
    if @membership.promote
      flash[:notice] = "User is now a group host"
    else
      flash[:notice] = "User is not eligible for promotion"
    end
    redirect_to group_memberships_path(@group)
    
  end
  protected
    
  def authorized?
    (current_user.member_of? @group) || %w[ index new ].include?(action_name)
  end
  
  def create_as_admin
    # if the group has no users, then let the first person join.

    # TODO: how could this happen if users are auto-added to groups they create?
    # just in case, first user to join a group becomes its admin
    @group.memberships.create :user => current_user, :group => @group, :role => 'administrator'

    flash[:notice] = 'You are the first person in this group'
    redirect_to group_url( @group)
  end

  def find_group
    raise ActiveRecord::RecordNotFound unless @group
  end

#  def create
#    return if request_already_exists?
#    @membership_request = MembershipRequest.new :user => current_user, :group => @group
#    @membership_request.attributes = params[:membership_request]
#    if @membership_request.save
#      flash[:notice] = 'Your request to join this group has been sent.'
#      redirect_to group_url(@group) and return
#    else
#      render :action => 'new'
#    end
#  end
#
#  # leave this group
#  def leave
#  end
#
#  def update
#    if @group.committee? and params[:group]
#      new_ids = params[:group][:user_ids]
#      @group.memberships.each do |m|  
#        m.destroy if m.user.member_of?(@group.parent) and not new_ids.include?(m.user_id.to_s)
#      end
#      new_ids.each do |id|
#        next unless id.any?
#        u = User.find(id)
#        @group.memberships.create(:user => u) if u.member_of?(@group.parent) and not u.direct_member_of?(@group)
#      end
#      message :success => 'member list updated'
#      redirect_to :action => 'list', :id => @group
#    end
#  end
#
#
#  def invite
#    @invitation = MembershipRequest.new :group => @group
#  end
#    
#  def send_invitation
#    requested_users = params[:invitation][:user_names].split(/\s*[,\s]\s*/).compact
#    real_users = requested_users.map do |login|
#      User.find_by_login login unless login.blank? 
#    end.compact
#    error_names = (requested_users - real_users.map(&:login)).select { |name| !name.blank? }
#    error_text = "not found: #{error_names.join(', ')}" unless error_names.empty?
#    existing_users = real_users.select { |user| @group.members.include? user }
#    existing_text = "for existing members: #{existing_users.map(&:login).join(", ")}" unless existing_users.empty?
#    real_users -= existing_users
#    @invitation = MembershipRequest.new :group => @group
#    @invitation.attributes = params[:invitation]
#    @invitation.errors.add(:user_names, error_text) if error_text
#    @invitation.errors.add(:user_names, existing_text) if existing_text
#    unless existing_text || error_text
#      real_users.each do |user| 
#        req = MembershipRequest.find_or_initialize_by_user_id_and_group_id user.id, @group.id
#        req.attributes = (params[:invitation] || {}).merge({ :approved_by => current_user })
#        #req.approved_by = current_user
#        req.save
#      end
#      flash[:notice] = "Sent #{real_users.size} invitations"
#      redirect_to group_url(@group)
#    else
#      @invitation.user_names = real_users.map(&:login).join(', ')
#      render :action => 'invite'
#    end
#  end
#  
#  def requests
#    @requests = @group.membership_requests.paginate(:page => params[:section],
#                                                    :order => "created_at DESC")
#  end
#  
#  def view_request
#    @membership_request = MembershipRequest.find(params[:id])
#  end
#
#  def approve
#    @membership_request = MembershipRequest.find(params[:id])
#    raise PermissionDenied unless @membership_request.group.allows?(current_user, :admin)
#    @membership_request.approved_by = current_user
#    if @membership_request.approve!
#      respond_to do |format|
#        format.html do
#          flash[:notice] = "Request Approved, Membership Granted"
#          redirect_to group_url(@group)
#        end
#        format.xml  { render :xml  => @group.membership_for( @membership_request.user) }
#        format.json { render :json => @group.membership_for( @membership_request.user) }
#      end
#    else
#      respond_to do |format|
#        format.html do
#          render :action => 'index'
#        end
#        format.json { render :json => @membership_request, :status => :unprocessable_entity }
#        format.xml  { render :xml  => @membership_request, :status => :unprocessable_entity }
#      end
#    end
#  end
#
#  def reject
#    @membership_request = MembershipRequest.find(params[:id])
#    raise PermissionDenied unless @membership_request.group.allows?(current_user, :admin)
#    if @membership_request.reject!
#      respond_to do |format|
#        format.html do
#          flash[:notice] = 'Request rejected'
#          redirect_to group_url(@group)
#        end
#        format.xml  { head :ok }
#        format.json { head :ok }
#      end
#    else
#      respond_to do |format|
#        format.html do
#          render :action => 'index'
#        end
#        format.json { render :json => @membership_request, :status => :unprocessable_entity }
#        format.xml  { render :xml  => @membership_request, :status => :unprocessable_entity }
#      end
#    end
#  end

#  def accept
#    @membership_request = MembershipRequest.find(params[:id])
#    raise PermissionDenied unless @membership_request.group.allows?(@membership_request.approved_by, :admin) and current_user = @membership_request.user
#    if @membership_request.approve!
#      respond_to do |format|
#        format.html do
#          flash[:notice] = "You are now a member of #{@group.name}"
#          redirect_to group_url(@group)
#        end
#        format.xml  { render :xml  => @group.membership_for( @membership_request.user) }
#        format.json { render :json => @group.membership_for( @membership_request.user) }
#      end
#    else
#      respond_to do |format|
#        format.html do
#          render :action => 'index'
#        end
#        format.json { render :json => @membership_request, :status => :unprocessable_entity }
#        format.xml  { render :xml  => @membership_request, :status => :unprocessable_entity }
#      end
#    end
#  end
#
#  #refuse a membership invitation
#  def refuse
#    @membership_request = MembershipRequest.find(params[:id])
#    raise PermissionDenied unless @membership_request.group.allows?(@membership_request.approved_by, :admin) and current_user = @membership_request.user
#    @membership_request.destroy
#    respond_to do |format|
#      format.html do
#        flash[:notice] = 'Invitation refused'
#        redirect_to group_url(@group)
#      end
#      format.xml  { head :ok }
#      format.json { head :ok }
#    end
#  end



#  def request_already_exists?
#    existing_membership_request = MembershipRequest.find_by_user_id_and_group_id current_user.id, @group.id
#    if existing_membership_request
#      if existing_membership_request.rejected? 
#        flash[:notice] = 'Your request to join this group was not granted.'
#      elsif existing_membership_request.pending?
#        flash[:notice] = 'Your request to join this group is being considered.'
#      else 
#        flash[:notice] = "Your request to join this group is #{existing_membership_request.state}."
#      end
#      redirect_to group_url(@group) and return true
#    end
#  end

end
