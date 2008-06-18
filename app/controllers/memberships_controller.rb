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

end
