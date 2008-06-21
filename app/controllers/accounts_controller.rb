class AccountsController < ApplicationController
  before_filter :not_logged_in_required

  # Activate a new account action
  def show
    User.find_and_activate!(params[:activation_code])
    flash[:notice] = "Welcome. Your account is ready. Please login."
    
    rescue ArgumentError, User::ActivationCodeNotFound
      flash[:error] = 'Activation code not found. Please try creating a new account'
    rescue User::AlreadyActivated
      flash[:notice] = 'Your account has already been activated.  You may log in below'
    ensure
      redirect_to login_path
  end

  # Display the signup form
  def new 
    @user = User.new(params[:user])
    @user.preferences.build :name => 'allow_info_sharing', :value => "1"
    @user.preferences.build :name => 'subscribe_to_email_list', :value => "1"
  end

  # Create a new Account
  def create
    @user = User.new params[:user] 
    @profile = @user.build_private_profile params[:profile].merge(:friend => true, :entity => @user )

    if @user.save && @profile.save 
      @user.add_to_democracy_in_action_groups
      flash[:notice] = "Thank you for signing up. <br />You must authenticate your account before you login. <br />Check your email inbox. <br/>There will be a short message telling you how to complete the creation of your account."
      redirect_to login_path
    else
      render :action => 'new' and return
    end
  end

end
