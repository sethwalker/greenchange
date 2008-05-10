class InvitationsController < ApplicationController
  include MessageSpawner
  before_filter :login_required
  before_filter :group_admin_required
  before_filter :get_invitation_type

  make_resourceful do
    actions :new, :destroy, :show
    before( :destroy ) { current_user.may! :admin, current_object }
    response_for(:show ) { redirect_to message_path( params[:id] ) }
    response_for(:destroy)  { |format| format.html { redirect_to :back }}
    response_for(:create)   do |format| 
      format.html do
        if current_object.group?
          redirect_to group_path(current_object.group) 
        elsif current_object.event?
          redirect_to event_path(current_object.event) 
        else
          redirect_to current_object
        end
      end
    end
  end

  def create
    invitation_params = object_parameters
    @invitations = Invitation.spawn( invitation_params )
    @valid_invitations, @invalid_invitations = @invitations.partition(&:valid?)
    @valid_invitations.each(&:save)

    if !@valid_invitations.empty?
      flash[:notice] = "Invitation sent to the following recipients: " + @valid_invitations.map { |m| m.recipient.display_name }.join(", " )
    end
    redirect_to me_inbox_path and return if @invalid_invitations.empty?

    # for redisplaying any errors, use a singular @invitation
    @invitation = distill_errors_to_singular( @invalid_invitations, Invitation.new( invitation_params ))
#    @invitation = Invitation.new invitation_params
#    @invitation.recipients = @invalid_invitations.map { |m| m.recipients }.join(', ')
#    #@invitation.errors.add :recipients, "couldn't send to: " + @invitation.recipients
#    @invalid_recipients = []
#    @invalid_invitations.each do |invalid_invite|
#      invalid_invite.errors.each do |attr, msg| 
#        ( @invalid_recipients << invalid_invite.recipients ) and next if attr == :recipient
#        @invitation.errors.add attr, msg
#      end
#    end
#    @invitation.errors.add :recipients, "couldn't send to: " + @invalid_recipients.join(', ')
    render :action => 'new'
  end

  def accept
    load_object
    before :accept
    current_object.accept!
    if current_object.accepted?
      after :accept
      flash[:notice] = "Invitation accepted"
      redirect_to me_inbox_path
    else
      after :accept_fails
      flash[:error] = "The invitation cannot be accepted"
      redirect_to me_inbox_path
    end
  end

  def ignore
    load_object
    before :ignore
    current_object.ignore!
    if current_object.ignored?
      after :ignore
      flash[:notice] = "You ignored this invitation"
      redirect_to me_inbox_path
    else
      after :ignore_fails
      flash[:error] = "The invitation cannot be ignored"
      redirect_to me_inbox_path
    end
  end

  protected

  def object_parameters
    defaults = super || {}
    invitable = {}
    if @group || ( get_invitation_type == 'group' ) 
      invitable[:group] = ( @group  || Group.new )
    elsif @event || ( get_invitation_type == 'event' ) 
      invitable[:event] = ( @event && @event.try(:data) ) || Event.new
    else
      invitable[:contact] = current_user
    end
  
    invitable[:sender] = current_user
    unless defaults[:recipients]
      invitable[:recipients] ||= @person.login if @person
    end
    defaults.merge invitable
  end

  def get_invitation_type
    @invitation_type ||= params[:invitation_type]
  end

  def load_context
    super
    if params[:invitation]
      @group = Group.find params[:invitation][:group_id] if params[:invitation][:group_id]
      if params[:invitation][:event_id]
        event = Event.find params[:invitation][:group_id] 
        @event = event.page
      end
    end
  end
  

end
