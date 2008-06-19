class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject += 'Please activate your new account'
    @body[:url] = "http://#{Crabgrass::Config.host}/activate/#{user.activation_code}"
  end

  def activation(user)
    setup_email(user)
    @subject  += "Your account has been activated"
    @body[:url] = "http://#{Crabgrass::Config.host}"
  end

  def forgot_password(user)
    setup_email(user)
    @subject += 'You have requested a change of password'
    @body[:url] = "http://#{Crabgrass::Config.host}/reset_password/#{user.password_reset_code}"
  end

  def reset_password(user)
    setup_email(user)
    @subject += 'Your password has been reset'
  end

  def message_received(message)
    setup_email(message.recipient)
  end

  def invitation_received(message)
    setup_email(message.recipient)
  end

  def comment_posted(post)
    setup_email(post.discussion.page.created_by)
  end

  protected
    def setup_email(user)
      @recipients   = "#{user.email}"
      @from         = Crabgrass::Config.email_sender
      @subject      = Crabgrass::Config.site_name + ": " 
      @sent_on      = Time.now
      @body[:user]  = user
    end
end
