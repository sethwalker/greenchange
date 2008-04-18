class NetworkInvitationMailer < ActionMailer::Base

  def invitation( invite )
    setup_email(invite.sender)
    @recipients = invite.recipient.email
    @subject      = "Invitation from #{user.display_name}: Check out the Green Change Network"
    @body[:recipient] = invite.recipient
    @body[:message] = invite.message
  end

  protected
    def setup_email(user)
      @from         = Crabgrass::Config.email_sender
      @sent_on      = Time.now
      @body[:sender]  = user
    end
end
