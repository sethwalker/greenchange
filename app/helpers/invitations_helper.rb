module InvitationsHelper
  def group_invitation?
    @invitation.group?
  end
  def event_invitation?
    @invitation.event?
  end
  def contact_invitation?
    @invitation.contact?
  end
end
