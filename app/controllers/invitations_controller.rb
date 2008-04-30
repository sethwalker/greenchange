class InvitationsController < ApplicationController
  before_filter :login_required
  before_filter :group_admin_required

  make_resourceful do
    actions :new, :create
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
    invitable = {}
    invitable[:group] = @group if @group
    invitable[:event] = @event if @event
    invitable[:sender] = current_user
    (super || {}).merge invitable
  end

  
end
