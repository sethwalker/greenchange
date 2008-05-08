require File.dirname(__FILE__) + '/../spec_helper'

describe AccountsController do
  before do
    @user = users(:quentin)
    @extra_user_params = {}
  end




  describe "new account" do
    it "should respond to new" do
      post :new
      response.should be_success
    end
  end

  describe "create" do
    it "should return to the signup page unless the terms and conditions are agreed to" do
      post :create, :user => {}, :profile => {}
      response.should render_template( 'new' )
    end

    it "should put an error in the flash about the agreement" do
      post :create, :user => {}, :profile => {}
      flash[:error].should match(/agree/)
    end

    it "should not allow signup if the user doesn't validate" do
      post :create, :user => {}, :profile => {}, :agreed_to_terms => true
      response.should render_template( 'new' )
    end

    it "should not allow signup if the profile doesn't validate" do
      post :create, :user => { :login => "JaneSmiegel", :password => "Jonas", :password_confirmation => "Jonas" }, :profile => {}, :agreed_to_terms => true
      response.should render_template( 'new' )
    end
    it "should post errors on the profile unless the profile validates" do
      post :create, :user => { :login => "JaneSmiegel", :password => "Jonas", :password_confirmation => "Jonas" }, :profile => {}, :agreed_to_terms => true
      assigns[:profile].should have_at_least(1).errors_on(:first_name)
    end
    
    describe "successful creation" do
      def act!
        post :create, :user => { :login => "JaneSmiegel", :password => "Jonas", :password_confirmation => "Jonas", :email => "jane@addiction.com" }.merge( @extra_user_params), :agreed_to_terms => true, :profile => { :first_name => "Jane", :last_name => "Smiegel"}
      end

      it "should create a new user" do
        lambda {  act! }.should change( User, :count ).by(1)
      end

      it "should create a new profile" do
        lambda {  act! }.should change( Profile, :count ).by_at_least(1)
      end

      it "should add a message to the flash" do
        act!
        flash[:notice].should match(/Thank/)
      end

      it "should require the new user to check email" do
        act!
        flash[:notice].should match(/check your email/i)
      end

      describe "user preferences" do
        before do
          @extra_user_params = { :preferences => { 'subscribe_to_email_list' => 1, 'allow_info_sharing' => false }}
        end
        it "should add user preferences if they are present" do
          act!
          assigns[:user].preferences.should_not be_empty
        end
        it 'sees preferences as valid' do
          act!
          assigns[:user].preferences.first.save.should be_true
        end
      end

      describe "attempt to use the same username" do
        it "should fail" do
          act!
          post :create, :user => { :login => "JaneSmiegel", :password => "Monas", :password_confirmation => "Monas", :email => "mane@addiction.com" }, :agreed_to_terms => true, :profile => { :first_name => "mane", :last_name => "miegel"}
          response.should render_template('new')
        end
      end
    end

  end

end
