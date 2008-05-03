class SessionsController < ApplicationController
  before_filter :not_logged_in_required, :only => [ :new, :create ]
  before_filter :login_required, :only => :destroy

  def new
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies["auth_token"] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end

      #for new users...
      if current_user.last_seen_at.nil?
        message = send_welcome_message(current_user)
        redirect_to( message_path(message) ) and return
      end

      redirect_to( params[:redirect] || me_path ) and return
    else
      flash[:error] = "Username or password is incorrect"
      render :action => 'new'
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_to login_path
  end

  protected
  def send_welcome_message(user)
    Message.create :recipient => user, :sender_id => ( Crabgrass::Config.welcome_message_user_id || user.id ), :subject => "Welcome to #{Crabgrass::Config.site_name}!", :body => WELCOME_TEXT_MARKUP
  end

  # TODO: move this to an e-mail
  
  WELCOME_TEXT_MARKUP = File.read "#{RAILS_ROOT}/app/views/account/welcome.txt"
end
