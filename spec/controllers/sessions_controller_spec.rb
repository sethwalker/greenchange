require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsController do
  before do
    @user = users(:quentin)
    @extra_user_params = {}
  end

  describe "signin" do
    before do
    end

    def act!( options = {} )
      login_options = { :login => @user.login, :password => 'test' }.merge options
      post :create, login_options
    end
    def second_act!
      get :new
    end
    it "should redirect to me/dashboard for most users" do
      @user.stub!(:last_seen_at).and_return(2.days.ago)
      User.stub!(:authenticate).and_return(@user) 
      act!
      response.should redirect_to( me_path) #:controller => '/me', :action => 'index' )
    end

    it "should redirect to the welcome message for new users" do
      @message = Message.create :sender => create_valid_user, :recipient => create_valid_user
      controller.stub!(:send_welcome_message).and_return(@message)
      act!
      response.should redirect_to( message_path(@message))
    end
    it "should assign current user" do
      controller.should_receive(:current_user=).at_least(1).times.with(users(:quentin))
      act!
    end
    it "should add the user to the session" do
      act!
      session[:user].should == users(:quentin).id
    end

    it "should not redirect unless the login works" do
      second_act!
      response.should_not be_redirect
    end

    it "totally should redirect if the login works" do
      act!
      second_act!
      response.should redirect_to( me_url )
    end

    it "should not redirect if the wrong password is given" do
      act! :password => 'badtest'
      response.should_not be_redirect
    end

    it "should set a cookie if the user requests rememeber_me" do
      act! :remember_me => "1"
      cookies["auth_token"].should_not be_nil
    end
    it "sets no cookie without the users request" do
      act! :remember_me => 0
      cookies["auth_token"].should be_nil
    end

    it "allows login via cookie" do
      @user.remember_me
      request.cookies["auth_token"] = mock_auth_token @user.remember_token
      get :new
      response.should redirect_to( me_url )
    end

    it "fails to log in expired cookies" do
      @user.remember_me
      @user.update_attribute :remember_token_expires_at, 5.minutes.ago
      request.cookies["auth_token"] = mock_auth_token @user.remember_token
      get :new
      response.should render_template('new')
    end

    it "fails to log in invalid cookie" do
      @user.remember_me
      request.cookies["auth_token"] = "blah blah blah"
      get :new
      response.should render_template('new')
    end

    describe "first time login" do
      it "should send a welcome message to the new user" do
        @user.stub!(:last_seen_at).and_return(nil)
        User.stub!(:authenticate).and_return(@user)
        controller.should_receive(:send_welcome_message)
        act!
      end
    end

  end
  describe "logout" do
    before do
      post :create, :login => @user.login, :password => 'test'
      get :destroy
    end

    it "should remove the user from the session" do
      session[:user].should be_nil
    end
    it "should redirect" do
      response.should be_redirect
    end
    it "deletes the remember_me token" do
      post :create, :login => @user.login, :password => 'test', :rememeber_me => "1"
      delete :destroy
      cookies["remember_me"].should be_nil
    end

  end

  def mock_auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end
  
end
