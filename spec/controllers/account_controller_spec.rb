require File.dirname(__FILE__) + '/../spec_helper'

describe AccountController do
  before do
    @user = users(:quentin)
  end

  describe "signin" do
    def act!
      post :login, :login => @user.login, :password => 'test'
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
    end

  end
end
