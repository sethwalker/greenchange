require File.dirname(__FILE__) + '/../spec_helper'
describe ProfilesController, "RESTFUL" do

  before do
    User.delete_all
    @current_user = login_valid_user
    User.stub!(:find_by_login).and_return(@current_user)
  end

  def profiles(*args)
    return create_valid_user.profiles.first if args[0] == :default
    create_valid_user( :profile => args.extract_options )
  end

  describe ProfilesController, "GET #show" do
    #define_models :users

    def act!; get :show, :person_id => ( @person_id || 1 ) ; end

    before do
      @person = create_valid_user
      @person_id = @person.login
      #User.stub!(:find).and_return(@person)
    end
    
    #it_assigns :profile
    it "assigns profile" do
      act!
      assigns[:profile].should_not be_nil
    end
    #it_renders :template, :show
    it "renders the show template" do
      act!
      response.should render_template( :show )
    end
    
    describe ProfilesController, "(xml)" do
      #define_models :users
      
      def act!; get :show, :person_id => 1, :format => 'xml' ; end

      #it_renders :xml, :profile
      it "renders xml" do
        act!
        #response.format.should be_xml
      end
    
    end

    describe ProfilesController, "(json)" do
      #define_models :users
      
      def act!; get :show, :person_id => 1, :format => 'json' ; end

      #it_renders :json, :profile
      it "renders json" do
        act!
        #response.format.should be_json
      end
    end

  
  end

  describe ProfilesController, "GET #edit" do
    #define_models :users
    def act!; get :edit, :person_id => 1 ; end
    
    before do
      @profile  = profiles(:default)
      Profile.stub!(:find).with('1').and_return(@profile)
    end

    #it_assigns :profile
    it "assigns @profile" do
      act!
      assigns[:profile].should_not be_nil
    end
    
    #it_renders :template, :edit
    it "renders the edit template" do
      act!
      response.should render_template(:edit)
    end
    
  end


  describe ProfilesController, "PUT #update" do
    before do
      updating_user = create_valid_user 
      @attributes = {}
      @profile = profiles(:default)
      updating_user.stub!(:private_profile).and_return(@profile)
      login_user updating_user
      User.stub!(:find_by_login).and_return(updating_user)
    end
    
    describe ProfilesController, "(successful save)" do
      #define_models :users
      def act!; put :update, :person_id => 1, :profile => @attributes ; end

      before do
        @profile.stub!(:save).and_return(true)
      end
      
      #it_assigns :profile, :flash => { :notice => :not_nil }
      it "assigns @profile" do
        act!
        assigns[:profile].should_not be_nil
      end
      it "assigns flash" do
        act!
        flash[:notice].should_not be_nil
      end
    
      #it_redirects_to { profile_path(@collecting) }
      it "redirects to saved item" do
        act!
        response.should redirect_to( person_profile_path(@profile.entity))
      end
    end

    describe ProfilesController, "(unsuccessful save)" do
      #define_models :users
      def act!; put :update, :person_id => 1, :profile => @attributes ; end

      before do
        @profile.stub!(:save).and_return(false)
        @profile.stub!(:update_attributes).and_return(false)
      end
      
      #it_assigns :profile
      it "assigns @profile" do
        act!
        assigns[:profile].should_not be_nil
      end
    
      #it_renders :template, :edit
      it "renders the edit template" do
        act!
        response.should render_template(:edit)
      end
    
    end
    
    describe ProfilesController, "(successful save, xml)" do
      #define_models :users
      def act!; put :update, :person_id => 1, :profile => @attributes, :format => 'xml' ; end

      before do
        @profile.stub!(:save).and_return(true)
      end
      
      #it_assigns :profile
      it "assigns @profile" do
        act!
        assigns[:profile].should_not be_nil
      end
    
      #it_renders :blank
      it "is blank" do
        act!
        response.body.should be_blank
      end
    end
    
    describe ProfilesController, "(unsuccessful save, xml)" do
      #define_models :users
      def act!; put :update, :person_id => 1, :profile => @attributes, :format => 'xml' ; end

      before do
        @profile.stub!(:save).and_return(false)
      end
      
      #it_assigns :profile
      it "assigns @profile" do
        act!
        assigns[:profile].should_not be_nil
      end
    
      #it_renders :xml, "profile.errors", :status => :unprocessable_entity
      it "renders xml" do
        #act!
        #response.format.should be_xml
        
      end
    end

    describe ProfilesController, "(successful save, json)" do
      #define_models :users
      def act!; put :update, :person_id => 1, :profile => @attributes, :format => 'json' ; end

      before do
        @profile.stub!(:save).and_return(true)
      end
      
      #it_assigns :profile
      it "assigns @profile" do
        act!
        assigns[:profile].should_not be_nil
      end
    
      #it_renders :blank
      it "is blank" do
        act!
        response.body.should be_blank
      end
    end
    
    describe ProfilesController, "(unsuccessful save, json)" do
      #define_models :users
      def act!; put :update, :person_id => 1, :profile => @attributes, :format => 'json' ; end

      before do
        @profile.stub!(:save).and_return(false)
      end
      
      #it_assigns :profile
      it "assigns @profile" do
        act!
        assigns[:profile].should_not be_nil
      end
    
      #it_renders :json, "profile.errors", :status => :unprocessable_entity
#      it "renders json" do
#        act!
#        #response.send(:format).should be_json
#        #response.status.should be_unprocessable_entity
#      end
    end

  end

  describe ProfilesController, "DELETE #destroy" do

    def act!; delete :destroy, :person_id => @current_user.to_param ; end
    
    before do
      @profile = profiles(:default)
      @profile.stub!(:destroy)
      @profile.stub!(:allows?).and_return(true)
      @current_user.stub!(:profile_for).and_return(@profile)
      @current_user.stub!(:private_profile).and_return(@profile)
      User.stub!(:find_by_login).and_return(@current_user)
      Profile.stub!(:find).and_return(@profile)
    end

    #it_assigns :profile
    it "assigns @profile" do
      act!
      assigns[:profile].should_not be_nil
    end
    
    #it_redirects_to { profiles_path }
    it "redirects to profiles" do
      act!
      response.should redirect_to( :controller => 'me', :action => 'index' )
    end
    
    describe ProfilesController, "(xml)" do
      #define_models :users
      def act!; delete :destroy, :person_id => 1, :format => 'xml' ; end

      #it_assigns :profile
      it "assigns @profile" do
        act!
        assigns[:profile].should_not be_nil
      end
    
      #it_renders :blank
      it "is blank" do
        act!
        response.body.should be_blank
      end
    end

    describe ProfilesController, "(json)" do
      #define_models :users
      def act!; delete :destroy, :person_id => @current_user.to_param, :format => 'json' ; end

      #it_assigns :profile
      it "assigns @profile" do
        act!
        assigns[:profile].should_not be_nil
      end
    
      #it_renders :blank
      it "is blank" do
        act!
        response.body.should be_blank
      end
    end

  
  end
end
 
describe ProfilesController do
  describe "when fetching a profile" do
    before do
      @viewing_user = @target_user = create_valid_user
      User.stub!(:find_by_login).and_return(@target_user)
    end
    def act!
      login_user @viewing_user
      get :edit, :person_id => @target_user
    end

    it "should assign the current users profile" do
      act!
      assigns[:profile].should == @target_user.private_profile
    end
    
  end
end

describe ProfilesController do
  describe "when updating a dependent collection" do
    before do
      @user = create_valid_user
      login_user @user
      @profile = @user.private_profile
      @profile_attributes = @profile.attributes
      User.stub!(:find_by_login).and_return(@user)
      @attributes = { :new => [] }
    end

    def act!
      put :update, :person_id => 1, :profile => @profile.attributes, :email_addresses => @attributes, :phone_numbers => {} 
    end

    it "should create new items" do
      @profile.email_addresses.delete_all
      @attributes[:new] << { :email_address => 'jan@jorgen.com', :email_type => 'personal' }
      @attributes[:new] << { :email_address => 'gjan@jorgen.com', :email_type => 'personal' }
      act!
      @profile.email_addresses.size.should == 2
    end
    it "should not save invalid items" do
      @profile.email_addresses.delete_all
      @attributes[:new] << { :email_address => 'jorgen.com', :email_type => 'personal' }
      act!
      response.should render_template( :edit )
    end
    it "should have errors on invalid items" do
      #pending "a plan for categorizing new-but-invald items on re-render"
      @profile.email_addresses.delete_all
      @attributes[:new] << { :email_address => 'jorgen.com', :email_type => 'personal' }
      act!
      assigns[:email_addresses].all?(&:valid?).should be_false 
    end

    it "should update existing items" do
      new_item = @profile.email_addresses.create :email_address => 'jo@jo.com', :email_type => 'other'
      @attributes[ new_item.id ] = { :email_address => 'bratt@jo.com', :email_type => 'personal' }
      act!
      @profile.email_addresses.first.email_address.should == 'bratt@jo.com'
    end

    describe "submitting a new blank item" do
      before do
        @attributes[ :new ] = [{ :email_address => '', :email_type => 'personal' }]
      end

      it "should not add a record" do
        @profile.email_addresses.delete_all
        act!
        @profile.email_addresses.size.should == 0
      end

      it "should show the result" do
        act!
        response.should redirect_to( me_profile_path )
      end
    end

    describe "invalid update to an existing item" do
      before do
        new_item = @profile.email_addresses.create :email_address => 'jo@jo.com', :email_type => 'other'
        @attributes[ new_item.id ] = { :email_address => 'jo', :email_type => 'personal' }
      end
      it "register to the item" do
        act!
        assigns[:email_addresses].first.email_address.should == 'jo'
      end

      it "create errors" do
        act!
        assigns[:email_addresses].first.should_not be_valid
      end

      it "re-render the edit template" do
        act!
        response.should render_template( :edit )
      end

    end

  end
end

