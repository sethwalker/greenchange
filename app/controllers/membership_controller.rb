=begin
Membership Controller
---------------------

All the relationships between users and groups are managed by this controller,
including join requests.

=end

class MembershipController < ApplicationController
  #layout 'groups'
  stylesheet 'groups'
  helper 'groups', 'application'
    
  before_filter :login_required, :except => ['list']

  ###### PUBLIC ACTIONS #########################################################
  
  def list
    
  end
  
  ###### USER ACTIONS #########################################################
  
  # request to join this group
  def join
    return unless request.post? # just show form on get.
    
    unless @group.users.any?
      # if the group has no users, then let the first person join.

      # TODO: how could this happen if users are auto-added to groups they create?
      # just in case, first user to join a group becomes its admin
      @group.memberships.create :user => current_user, :group => @group, :role => 'administrator'

      message :success => 'You are the first person in this group'
      redirect_to :action => 'show', :id => @group
      return
    end
    page = Page.make :request_to_join_group, :user => current_user, :group => @group
    if page.save
      message :success => 'Your request to join this group has been sent.'
      discussion = Page.make :join_discussion, :user => current_user, :group => @group, :message => params[:message]
      discussion.save
      page.add_link discussion
      redirect_to url_for(:controller => 'requests')
    else
      message :object => page
      render :action => 'show'
    end
  end

  ###### MEMBER ACTIONS #########################################################
  
  # leave this group
  def leave
    return unless request.post? # show form on get
    
    current_user.groups.delete(@group)
    message :success => 'You have been removed from %s' / @group.name
    redirect_to url_for_group(@group)
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
    params[:users].split(/\s/).each do |login|
      next if login.empty?
      if user = User.find_by_login(login)
        page = Page.make :invite_to_join_group, :group => @group,
          :user => user, :from => current_user
        if page.save
          discussion = Page.make :invite_discussion, :group => @group,
            :user => user, :from => current_user, :message => params[:message]
          discussion.save
          page.add_link discussion
        end
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
    @pages = @group.pages.
      allowed(current_user).
      paginate(:page => params[:section], 
               :order => "created_at DESC", 
               :conditions => ["pages.flow = ?", FLOW[:membership]])
    @columns = [:title, :created_by, :created_at, :contributors_count]
  end
  
  protected
    
  def context
    group_context
    add_context 'membership', url_for(:controller=>'membership', :action => 'list', :id => @group)
  end
  
  prepend_before_filter :fetch_group
  def fetch_group
    @group = Group.get_by_name params[:id].sub(' ','+') if params[:id]
    if @group
      @group_type = @group.class.to_s.downcase
      return true
    else
      render :action => 'not_found'
      return false
    end
  end
  
  def authorized?
    non_members_post_allowed = %w(join)
    non_members_get_allowed = %w(list) + non_members_post_allowed
    if request.get? and non_members_get_allowed.include? params[:action]
      return true
    elsif request.post? and non_members_post_allowed.include? params[:action]
      return true
    else
      return(logged_in? and current_user.member_of? @group)
    end
  end
  
end
