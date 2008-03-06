require File.dirname(__FILE__) + '/../spec_helper'
describe CollectingsController, "RESTFUL" do

  before do
    login_valid_user
  end
  def collectings(name)
    Collecting.create! :collection => Collection.create!( :page => create_valid_page ), :collectable => create_valid_asset
  end

  describe CollectingsController, "GET #index" do
    #define_models :users

    def act!; get :index ; end

    before do
      @collectings = []
      Collecting.stub!(:find).with(:all).and_return(@collectings)
    end
    
    #it_assigns :collectings
    it "assigns collectings" do
      act!
      assigns[:collectings].should_not be_nil
    end

    #it_renders :template, :index
    it "renders the index template" do
      act!
      response.should render_template( :index )
    end

    describe CollectingsController, "(xml)" do
      #define_models :users
      
      def act!; get :index, :format => 'xml' ; end

      it "assigns collectings" do
        act!
        assigns[:collectings].should_not be_nil
      end
      #it_renders :xml, :collectings
      #it "renders xml" do
      #  act!
        #response.format.should be_xml
      #end
    end

    describe CollectingsController, "(json)" do
      #define_models :users
      
      def act!; get :index, :format => 'json' ; end

      it "assigns collectings" do
        act!
        assigns[:collectings].should_not be_nil
      end
      #it_renders :json, :collectings
      it "renders json" do
        act!
        #response.format.should be_json
      end
    end

  
  end

  describe CollectingsController, "GET #show" do
    #define_models :users

    def act!; get :show, :id => 1 ; end

    before do
      @collecting  = collectings(:default)
      Collecting.stub!(:find).with('1').and_return(@collecting)
    end
    
    #it_assigns :collecting
      it "assigns collecting" do
        act!
        assigns[:collecting].should_not be_nil
      end
    #it_renders :template, :show
    it "renders the show template" do
      act!
      response.should render_template( :show )
    end
    
    describe CollectingsController, "(xml)" do
      #define_models :users
      
      def act!; get :show, :id => 1, :format => 'xml' ; end

      #it_renders :xml, :collecting
      it "renders xml" do
        act!
        #response.format.should be_xml
      end
    
    end

    describe CollectingsController, "(json)" do
      #define_models :users
      
      def act!; get :show, :id => 1, :format => 'json' ; end

      #it_renders :json, :collecting
      it "renders json" do
        act!
        #response.format.should be_json
      end
    end

  
  end

  describe CollectingsController, "GET #new" do
    #define_models :users
    def act!; get :new ; end
    before do
      @collecting  = Collecting.new
    end

    it "assigns @collecting" do
      act!
      assigns[:collecting].should be_new_record
    end
    
    #it_renders :template, :new
    it "renders the new template" do
      act!
      response.should render_template(:new)
    end
    
    
    describe CollectingsController, "(xml)" do
      #define_models :users
      def act!; get :new, :format => 'xml' ; end

      #it_renders :xml, :collecting
      it "renders xml" do
        act!
        #response.format.should be_xml
      end
    end

    describe CollectingsController, "(json)" do
      #define_models :users
      def act!; get :new, :format => 'json' ; end

      #it_renders :json, :collecting
      it "renders json" do
        act!
        #response.format.should be_json
      end
    end

  
  end

  describe CollectingsController, "GET #edit" do
    #define_models :users
    def act!; get :edit, :id => 1 ; end
    
    before do
      @collecting  = collectings(:default)
      Collecting.stub!(:find).with('1').and_return(@collecting)
    end

    #it_assigns :collecting
    it "assigns @collecting" do
      act!
      assigns[:collecting].should_not be_nil
    end
    
    #it_renders :template, :edit
    it "renders the edit template" do
      act!
      response.should render_template(:edit)
    end
    
  end

  describe CollectingsController, "POST #create" do
    before do
      @attributes = {}
      @collecting = mock_model Collecting, :new_record? => false, :errors => [], :name => "", :collectable => mock_model( Asset, :name => "Jack" ), :collection => mock_model( Collection, :name => "Laina" )
      Collecting.stub!(:new).with(@attributes).and_return(@collecting)
    end
    
    describe CollectingsController, "(successful creation)" do
      #define_models :users
      def act!; post :create, :collecting => @attributes ; end

      before do
        @collecting.stub!(:save).and_return(true)
      end
      
      #it_assigns :collecting, :flash => { :notice => :not_nil }
      it "assigns @collecting" do
        act!
        assigns[:collecting].should_not be_nil
      end
      it "assigns flash" do
        act!
        flash[:notice].should_not be_nil
      end
    
      #it_redirects_to { collecting_path(@collecting) }
      it "redirects to new collecting" do
        act!
        response.should redirect_to( :controller => 'collectings', :id => @collecting.id ) 
      end
    end

    describe CollectingsController, "(unsuccessful creation)" do
      #define_models :users
      def act!; post :create, :collecting => @attributes ; end

      before do
        @collecting.stub!(:save).and_return(false)
      end
      
      #it_assigns :collecting
      it "assigns @collecting" do
        act!
        assigns[:collecting].should_not be_nil
      end
    
      #it_renders :template, :new
      it "renders the new template" do
        act!
        response.should render_template(:new)
      end
    
    end
    
    describe CollectingsController, "(successful creation, xml)" do
      #define_models :users
      def act!; post :create, :collecting => @attributes, :format => 'xml' ; end

      before do
        @collecting.stub!(:save).and_return(true)
        @collecting.stub!(:to_xml).and_return("mocked content")
      end
      
      #it_assigns :collecting, :headers => { :Location => lambda { collecting_url(@collecting) } }
      it "assigns @collecting" do
        act!
        assigns[:collecting].should_not be_nil
      end
    
      #it_renders :xml, :collecting, :status => :created
#      it "renders xml" do
#        act!
#        response.body.should match( collecting.to_xml )
#        response.status.should be_created
#      end
    end
    
    describe CollectingsController, "(unsuccessful creation, xml)" do
      #define_models :users
      def act!; post :create, :collecting => @attributes, :format => 'xml' ; end

      before do
        @collecting.stub!(:save).and_return(false)
      end
      
      #it_assigns :collecting
      it "assigns @collecting" do
        act!
        assigns[:collecting].should_not be_nil
      end
    
#      #it_renders :xml, "collecting.errors", :status => :unprocessable_entity
#      it "renders xml" do
#        act!
#        response.status.should be_unprocessable_entity
#      end
    end

    describe CollectingsController, "(successful creation, json)" do
      #define_models :users
      def act!; post :create, :collecting => @attributes, :format => 'json' ; end

      before do
        @collecting.stub!(:save).and_return(true)
        @collecting.stub!(:to_json).and_return("mocked content")
      end
      
      #it_assigns :collecting, :headers => { :Location => lambda { collecting_url(@collecting) } }
      it "assigns @collecting" do
        act!
        assigns[:collecting].should_not be_nil
      end
    
#      #it_renders :json, :collecting, :status => :created
#      it "renders json" do
#        act!
#        #response.format.should be_json
#        response.status.should be_created
#      end
    end
    
    describe CollectingsController, "(unsuccessful creation, json)" do
      #define_models :users
      def act!; post :create, :collecting => @attributes, :format => 'json' ; end

      before do
        @collecting.stub!(:save).and_return(false)
      end
      
      #it_assigns :collecting
      it "assigns @collecting" do
        act!
        assigns[:collecting].should_not be_nil
      end
    
#      #it_renders :json, "collecting.errors", :status => :unprocessable_entity
#      it "renders json" do
#        act!
#        #response.format.should be_json
#        response.status.should be_unprocessable_entity
#      end
    end

  end

  describe CollectingsController, "PUT #update" do
    before do
      @attributes = {}
      @collecting = collectings(:default)
      Collecting.stub!(:find).with('1').and_return(@collecting)
    end
    
    describe CollectingsController, "(successful save)" do
      #define_models :users
      def act!; put :update, :id => 1, :collecting => @attributes ; end

      before do
        @collecting.stub!(:save).and_return(true)
      end
      
      #it_assigns :collecting, :flash => { :notice => :not_nil }
      it "assigns @collecting" do
        act!
        assigns[:collecting].should_not be_nil
      end
      it "assigns flash" do
        act!
        flash[:notice].should_not be_nil
      end
    
      #it_redirects_to { collecting_path(@collecting) }
      it "redirects to saved item" do
        act!
        response.should redirect_to( :controller => 'collectings', :id => @collecting.id ) 
      end
    end

    describe CollectingsController, "(unsuccessful save)" do
      #define_models :users
      def act!; put :update, :id => 1, :collecting => @attributes ; end

      before do
        @collecting.stub!(:save).and_return(false)
      end
      
      #it_assigns :collecting
      it "assigns @collecting" do
        act!
        assigns[:collecting].should_not be_nil
      end
    
      #it_renders :template, :edit
      it "renders the edit template" do
        act!
        response.should render_template(:edit)
      end
    
    end
    
    describe CollectingsController, "(successful save, xml)" do
      #define_models :users
      def act!; put :update, :id => 1, :collecting => @attributes, :format => 'xml' ; end

      before do
        @collecting.stub!(:save).and_return(true)
      end
      
      #it_assigns :collecting
      it "assigns @collecting" do
        act!
        assigns[:collecting].should_not be_nil
      end
    
      #it_renders :blank
      it "is blank" do
        act!
        response.body.should be_blank
      end
    end
    
    describe CollectingsController, "(unsuccessful save, xml)" do
      #define_models :users
      def act!; put :update, :id => 1, :collecting => @attributes, :format => 'xml' ; end

      before do
        @collecting.stub!(:save).and_return(false)
      end
      
      #it_assigns :collecting
      it "assigns @collecting" do
        act!
        assigns[:collecting].should_not be_nil
      end
    
      #it_renders :xml, "collecting.errors", :status => :unprocessable_entity
      it "renders xml" do
        #act!
        #response.format.should be_xml
        
      end
    end

    describe CollectingsController, "(successful save, json)" do
      #define_models :users
      def act!; put :update, :id => 1, :collecting => @attributes, :format => 'json' ; end

      before do
        @collecting.stub!(:save).and_return(true)
      end
      
      #it_assigns :collecting
      it "assigns @collecting" do
        act!
        assigns[:collecting].should_not be_nil
      end
    
      #it_renders :blank
      it "is blank" do
        act!
        response.body.should be_blank
      end
    end
    
    describe CollectingsController, "(unsuccessful save, json)" do
      #define_models :users
      def act!; put :update, :id => 1, :collecting => @attributes, :format => 'json' ; end

      before do
        @collecting.stub!(:save).and_return(false)
      end
      
      #it_assigns :collecting
      it "assigns @collecting" do
        act!
        assigns[:collecting].should_not be_nil
      end
    
      #it_renders :json, "collecting.errors", :status => :unprocessable_entity
#      it "renders json" do
#        act!
#        #response.send(:format).should be_json
#        #response.status.should be_unprocessable_entity
#      end
    end

  end

  describe CollectingsController, "DELETE #destroy" do

    def act!; delete :destroy, :id => 1 ; end
    
    before do
      @collecting = collectings(:default)
      @collecting.stub!(:destroy)
      Collecting.stub!(:find).with('1').and_return(@collecting)
    end

    #it_assigns :collecting
    it "assigns @collecting" do
      act!
      assigns[:collecting].should_not be_nil
    end
    
    #it_redirects_to { collectings_path }
    it "redirects to collectings" do
      act!
      response.should redirect_to( :controller => 'collectings', :action => 'index' )
    end
    
    describe CollectingsController, "(xml)" do
      #define_models :users
      def act!; delete :destroy, :id => 1, :format => 'xml' ; end

      #it_assigns :collecting
      it "assigns @collecting" do
        act!
        assigns[:collecting].should_not be_nil
      end
    
      #it_renders :blank
      it "is blank" do
        act!
        response.body.should be_blank
      end
    end

    describe CollectingsController, "(json)" do
      #define_models :users
      def act!; delete :destroy, :id => 1, :format => 'json' ; end

      #it_assigns :collecting
      it "assigns @collecting" do
        act!
        assigns[:collecting].should_not be_nil
      end
    
      #it_renders :blank
      it "is blank" do
        act!
        response.body.should be_blank
      end
    end

  
  end
end

