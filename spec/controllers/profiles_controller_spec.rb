require File.dirname(__FILE__) + '/../spec_helper'
describe ProfilesController, "RESTFUL" do

  before do
    login_valid_user
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
      @person_id = @person.id
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
      
      def act!; get :show, :id => 1, :format => 'xml' ; end

      #it_renders :xml, :profile
      it "renders xml" do
        act!
        #response.format.should be_xml
      end
    
    end

    describe ProfilesController, "(json)" do
      #define_models :users
      
      def act!; get :show, :id => 1, :format => 'json' ; end

      #it_renders :json, :profile
      it "renders json" do
        act!
        #response.format.should be_json
      end
    end

  
  end

  describe ProfilesController, "GET #new" do
    #define_models :users
    def act!; get :new ; end
    before do
      controller.current_user.private_profile.destroy
      controller.current_user.reload
      @profile  = Profile.new
    end

    it "assigns @profile" do
      act!
      assigns[:profile].should be_new_record
    end
    
    #it_renders :template, :new
    it "renders the new template" do
      act!
      response.should render_template(:new)
    end
    
    
    describe ProfilesController, "(xml)" do
      #define_models :users
      def act!; get :new, :format => 'xml' ; end

      #it_renders :xml, :profile
      it "renders xml" do
        act!
        #response.format.should be_xml
      end
    end

    describe ProfilesController, "(json)" do
      #define_models :users
      def act!; get :new, :format => 'json' ; end

      #it_renders :json, :profile
      it "renders json" do
        act!
        #response.format.should be_json
      end
    end

  
  end

  describe ProfilesController, "GET #edit" do
    #define_models :users
    def act!; get :edit, :id => 1 ; end
    
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

  describe ProfilesController, "POST #create" do
    before do
      @attributes = { }
      @profile = create_valid_user.private_profile
      Profile.stub!(:new).with(@attributes).and_return(@profile)
    end
    
    describe ProfilesController, "(successful creation)" do
      #define_models :users
      def act!; post :create, :profile => @attributes ; end

      before do
        @profile.stub!(:save).and_return(true)
      end
      
      #it_assigns :profile, :flash => { :notice => :not_nil }
      it "assigns @profile" do
        act!
        assigns[:profile].should_not be_nil
      end
    
      #it_redirects_to { profile_path(@collecting) }
      it "redirects to new profile" do
        act!
        response.should redirect_to(:controller => '/profiles', :action => 'show' )
      end
    end

    describe ProfilesController, "(unsuccessful creation)" do
      #define_models :users
      def act!; post :create, :profile => @attributes ; end

      before do
        @profile.stub!(:save).and_return(false)
      end
      
      #it_assigns :profile
      it "assigns @profile" do
        act!
        assigns[:profile].should_not be_nil
      end
    
      #it_renders :template, :new
      it "renders the new template" do
        act!
        response.should render_template(:new)
      end
    
    end
    
    describe ProfilesController, "(successful creation, xml)" do
      #define_models :users
      def act!; post :create, :profile => @attributes, :format => 'xml' ; end

      before do
        @profile.stub!(:save).and_return(true)
        @profile.stub!(:to_xml).and_return("mocked content")
      end
      
      #it_assigns :profile, :headers => { :Location => lambda { collecting_url(@collecting) } }
      it "assigns @profile" do
        act!
        assigns[:profile].should_not be_nil
      end
    
      #it_renders :xml, :profile, :status => :created
#      it "renders xml" do
#        act!
#        response.body.should match( profile.to_xml )
#        response.status.should be_created
#      end
    end
    
    describe ProfilesController, "(unsuccessful creation, xml)" do
      #define_models :users
      def act!; post :create, :profile => @attributes, :format => 'xml' ; end

      before do
        @profile.stub!(:save).and_return(false)
      end
      
      #it_assigns :profile
      it "assigns @profile" do
        act!
        assigns[:profile].should_not be_nil
      end
    
#      #it_renders :xml, "profile.errors", :status => :unprocessable_entity
#      it "renders xml" do
#        act!
#        response.status.should be_unprocessable_entity
#      end
    end

    describe ProfilesController, "(successful creation, json)" do
      #define_models :users
      def act!; post :create, :profile => @attributes, :format => 'json' ; end

      before do
        @profile.stub!(:save).and_return(true)
        @profile.stub!(:to_json).and_return("mocked content")
      end
      
      #it_assigns :profile, :headers => { :Location => lambda { collecting_url(@collecting) } }
      it "assigns @profile" do
        act!
        assigns[:profile].should_not be_nil
      end
    
#      #it_renders :json, :profile, :status => :created
#      it "renders json" do
#        act!
#        #response.format.should be_json
#        response.status.should be_created
#      end
    end
    
    describe ProfilesController, "(unsuccessful creation, json)" do
      #define_models :users
      def act!; post :create, :profile => @attributes, :format => 'json' ; end

      before do
        @profile.stub!(:save).and_return(false)
      end
      
      #it_assigns :profile
      it "assigns @profile" do
        act!
        assigns[:profile].should_not be_nil
      end
    
#      #it_renders :json, "profile.errors", :status => :unprocessable_entity
#      it "renders json" do
#        act!
#        #response.format.should be_json
#        response.status.should be_unprocessable_entity
#      end
    end

  end

  describe ProfilesController, "PUT #update" do
    before do
      updating_user = create_valid_user 
      @attributes = {}
      @profile = profiles(:default)
      updating_user.stub!(:private_profile).and_return(@profile)
      login_user updating_user
    end
    
    describe ProfilesController, "(successful save)" do
      #define_models :users
      def act!; put :update, :id => 1, :profile => @attributes ; end

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
        response.should redirect_to( me_profile_url )
      end
    end

    describe ProfilesController, "(unsuccessful save)" do
      #define_models :users
      def act!; put :update, :id => 1, :profile => @attributes ; end

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
      def act!; put :update, :id => 1, :profile => @attributes, :format => 'xml' ; end

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
      def act!; put :update, :id => 1, :profile => @attributes, :format => 'xml' ; end

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
      def act!; put :update, :id => 1, :profile => @attributes, :format => 'json' ; end

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
      def act!; put :update, :id => 1, :profile => @attributes, :format => 'json' ; end

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

    def act!; delete :destroy, :id => 1 ; end
    
    before do
      @profile = profiles(:default)
      @profile.stub!(:destroy)
      Profile.stub!(:find).with('1').and_return(@profile)
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
      def act!; delete :destroy, :id => 1, :format => 'xml' ; end

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
      def act!; delete :destroy, :id => 1, :format => 'json' ; end

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
    end
    def act!
      login_user @viewing_user
      get :edit, :person => @target_user
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
      @attributes = { :new => [] }
    end

    def act!
      put :update, :profile => @profile.attributes, :email_addresses => @attributes, :phone_numbers => {} 
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
      pending "a plan for categorizing new-but-invald items on re-render"
      @profile.email_addresses.delete_all
      @attributes[:new] << { :email_address => 'jorgen.com', :email_type => 'personal' }
      act!
      @profile.email_addresses.all?(&:valid).should be_false 
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

