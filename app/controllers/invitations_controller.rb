class InvitationsController < ApplicationController
  before_filter :login_required
  before_filter :group_admin_required
  before_filter :get_invitation_type

  make_resourceful do
    actions :new
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
    @invitation = Invitation.new invitation_params
    @invitation.recipients = @invalid_invitations.map { |m| m.recipients }.join(', ')
    @invitation.errors.add :recipients, "couldn't send to: " + @invitation.recipients
    render :action => 'new'
  end

  def accept
    load_object
    before :accept
    if current_object.accept!
      after :accept
      redirect_to me_inbox_path
    else
      after :accept_fails
      redirect_to me_inbox_path
    end
  end

  def ignore
    load_object
    before :ignore
    if current_object.ignore!
      after :ignore
      redirect_to me_inbox_path
    else
      after :ignore_fails
      redirect_to me_inbox_path
    end
  end

  protected

  # redirects to the invitable rather than the invitation display
  def set_default_redirect(default_path, options={})
    return super(default_path, options) unless action_name =~ /create/ and ( @group || @event )
    super group_path(@group), options if @group
    super event_path(@event), options if @event
  end
  
  def object_parameters
    defaults = super || {}
    invitable = {}
    invitable[:group] = @group if @group
    invitable[:event] = @event if @event
    invitable[:sender] = current_user
    unless defaults[:recipients]
      invitable[:recipients] ||= @person.login if @person
    end
    defaults.merge invitable
  end

  def get_invitation_type
    @invitation_type = params[:invitation_type]
  end
  
end
