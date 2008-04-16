class AccountController < ApplicationController

  stylesheet 'login'

  def index
    if logged_in?
      redirect_to me_url and return
    end
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies["auth_token"] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end

      #for new users...
      if current_user.last_seen_at.nil?
        message = send_welcome_message(current_user)
        redirect_to message_path(message)
      else
        redirect_to params[:redirect] || me_path
      end

    else
      flash[:error] = "Username or password is incorrect"
    end
  end

  # Activate action
  def show
    User.find_and_activate!(params[:activation_code])
    flash[:notice] = "Welcome. Your account is ready. Please login."
    redirect_to login_path
    
    rescue ArgumentError, User::ActivationCodeNotFound
      flash[:error] = 'Activation code not found. Please try creating a new account'
      redirect_to login_path
    #rescue User::ActivationCodeNotFound
    #  flash[:notice] = 'Activation code not found. Please try creating a new account'
    #  redirect_to new_user_path
    rescue User::AlreadyActivated
      flash[:notice] = 'Your account has already been activated.  You may log in below'
      redirect_to login_path
  end

  def new 
    @user = User.new(params[:user])
    @user.preferences.build :name => 'allow_info_sharing', :value => true
    @user.preferences.build :name => 'subscribe_to_email_list', :value => true
  end
  alias :signup :new

  def create
    @user = User.new params[:user] 
    @profile = @user.build_private_profile params[:profile].merge(:friend => true, :entity => @user )
    @public_profile = @user.build_public_profile params[:profile].merge(:stranger=> true, :entity => @user )

    unless params[:agreed_to_terms] 
      flash[:error] = "You must agree to the terms and conditions to sign up"
      render :action => 'signup' and return 
    end

    if @user.save && @profile.save && @public_profile.save
      #self.current_user = @user
      flash[:notice] = "Thanks for signing up! Please check your email to activate your account before logging in."
      redirect_to login_path
      #redirect_to params[:redirect] || message_url(message)
    else
      render :action => 'signup' and return
    end
  end

  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_to :controller => '/account', :action => 'index'
  end

  #def welcome
  #end

  protected
  def send_welcome_message(user)
    Message.create :recipient => user, :sender_id => ( Crabgrass::Config.welcome_message_user_id || user.id ), :subject => "Welcome to #{Crabgrass::Config.site_name}!", :body => WELCOME_TEXT_MARKUP
  end

  # TODO: move this to an e-mail
  
  WELCOME_TEXT_MARKUP = File.read "#{RAILS_ROOT}/app/views/account/welcome.txt"
end

