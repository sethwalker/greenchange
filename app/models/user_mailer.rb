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
    subject "#{message.sender.display_name} sent you a message on Green Change"
    body :subject => message.subject, 
      :text => message.body,
      :reply_url => message_url(message, :host => Crabgrass::Config.host),
      :login_url => login_url(:host => Crabgrass::Config.host)
  end

  def invitation_received(message)
    setup_email(message.recipient)
    subject "#{message.sender.display_name} sent you an invitation on Green Change"
    body :text => message.body,
      :reply_url => message_url(message, :host => Crabgrass::Config.host),
      :login_url => login_url(:host => Crabgrass::Config.host)
  end

  def contact_request_received(message)
    setup_email(message.recipient)
    subject "#{message.contact.display_name} wants to be your contact on Green Change"
    body :text => message.body,
      :reply_url => message_url(message, :host => Crabgrass::Config.host),
      :login_url => login_url(:host => Crabgrass::Config.host)
  end

  def comment_posted(post)
    poster = post.discussion.page.created_by
    setup_email(poster)
    subject "#{poster.display_name} left you a comment on Green Change"
    body :page_url => page_url(post.discussion.page, :host => Crabgrass::Config.host),
      :login_url => login_url(:host => Crabgrass::Config.host)
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
