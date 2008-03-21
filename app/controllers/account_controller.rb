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
      redirect_to params[:redirect] || {:controller => '/me', :action => 'index'}
    else
      flash[:error] = "Username or password is incorrect"
    end
  end

  def new 
    @user = User.new(params[:user])
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
      self.current_user = @user
      send_welcome_message(current_user)
      flash[:notice] = "Thanks for signing up!"
      redirect_to params[:redirect] || { :controller => '/account', :action => 'welcome' }
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

  def welcome
    render :text => GreenCloth.new(WELCOME_TEXT_MARKUP).to_html, :layout => 'me'
  end

  protected
  def send_welcome_message(user)
    page = Page.make :private_message, :to => user, :from => user, :title => "Welcome to #{Crabgrass::Config.site_name}!", :body => WELCOME_TEXT_MARKUP
    page.save
  end

  # TODO: move this to an e-mail
  
  WELCOME_TEXT_MARKUP = File.read "#{RAILS_ROOT}/app/views/account/welcome.txt"
end

