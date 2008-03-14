require File.dirname(__FILE__) + '/../spec_helper'

describe AccountController do
  before do
    @user = users(:quentin)
  end

  describe "signin" do
    before do
    end

    def act!( options = {} )
      login_options = { :login => @user.login, :password => 'test' }.merge options
      post :login, login_options
    end
    def second_act!
      get :index
    end
    it "should redirect to me/dashboard" do
      act!
      response.should redirect_to( :controller => '/me', :action => 'index' )
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
      get :index
      response.should redirect_to( me_url )
    end

    it "fails to log in expired cookies" do
      @user.remember_me
      @user.update_attribute :remember_token_expires_at, 5.minutes.ago
      request.cookies["auth_token"] = mock_auth_token @user.remember_token
      get :index
      response.should render_template('index')
    end

    it "fails to log in invalid cookie" do
      @user.remember_me
      request.cookies["auth_token"] = "blah blah blah"
      get :index
      response.should render_template('index')
    end
  end



  it "should respond to index" do
    get :index
    response.should be_success
  end

  describe "signup" do
    it "should also respond to new" do
      post :new
      response.should be_success
    end
  end

  describe "create" do
    it "should return to the signup page unless the terms and conditions are agreed to" do
      post :create, :user => {}, :profile => {}
      response.should render_template( 'account/signup' )
    end

    it "should put an error in the flash about the agreement" do
      post :create, :user => {}, :profile => {}
      flash[:error].should match(/agree/)
    end

    it "should not allow signup if the user doesn't validate" do
      post :create, :user => {}, :profile => {}, :agreed_to_terms => true
      response.should render_template( 'account/signup' )
    end

    it "should not allow signup if the profile doesn't validate" do
      post :create, :user => { :login => "JaneSmiegel", :password => "Jonas", :password_confirmation => "Jonas" }, :profile => {}, :agreed_to_terms => true
      response.should render_template( 'account/signup' )
    end
    it "should post errors on the profile unless the profile validates" do
      post :create, :user => { :login => "JaneSmiegel", :password => "Jonas", :password_confirmation => "Jonas" }, :profile => {}, :agreed_to_terms => true
      assigns[:profile].should have_at_least(1).errors_on(:first_name)
    end
    
    describe "successful creation" do
      def act!
        post :create, :user => { :login => "JaneSmiegel", :password => "Jonas", :password_confirmation => "Jonas", :email => "jane@addiction.com" }, :agreed_to_terms => true, :profile => { :first_name => "Jane", :last_name => "Smiegel"}
      end

      it "should create a new user" do
        lambda {  act! }.should change( User, :count ).by(1)
      end

      it "should create a new profile" do
        lambda {  act! }.should change( Profile, :count ).by(1)
      end

      it "should add a message to the flash" do
        act!
        flash[:notice].should match(/Thanks/)
      end

      it "should send a welcome message to the new user" do
        controller.should_receive(:send_welcome_message)
        act!
      end

      it "should assign the new user as the current user" do
        controller.stub!(:current_user).and_return(User.new)
        controller.should_receive(:current_user=)
        act!
      end

      describe "attempt to use the same username" do
        it "should fail" do
          act!
          post :create, :user => { :login => "JaneSmiegel", :password => "Monas", :password_confirmation => "Monas", :email => "mane@addiction.com" }, :agreed_to_terms => true, :profile => { :first_name => "mane", :last_name => "miegel"}
          response.should render_template('account/signup')
        end
      end
    end

  end

  describe "logout" do
    before do
      post :login, :login => @user.login, :password => 'test'
      get :logout
    end

    it "should remove the user from the session" do
      session[:user].should be_nil
    end
    it "should redirect" do
      response.should be_redirect
    end
    it "deletes the remember_me token" do
      post :login, :login => @user.login, :password => 'test', :rememeber_me => "1"
      get :logout
      cookies["remember_me"].should be_nil
    end

  end
  def mock_auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end
  
end
