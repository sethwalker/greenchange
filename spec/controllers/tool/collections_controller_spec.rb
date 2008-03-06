require File.dirname(__FILE__) + '/../../spec_helper'
describe Tool::CollectionsController, "RESTFUL" do

  before do
    login_valid_user
  end
  def collections(name)
    Collection.create! :page => create_valid_page
  end

  describe Tool::CollectionsController, "GET #index" do
    #define_models :users

    def act!; get :index ; end

    before do
      @collections = []
      Tool::Collection.stub!(:find).with(:all).and_return(@collections)
    end
    
    #it_assigns :collections
    it "assigns collections" do
      act!
      assigns[:collections].should_not be_nil
    end

    #it_renders :template, :index
    it "renders the index template" do
      act!
      response.should render_template( :index )
    end

    describe Tool::CollectionsController, "(xml)" do
      #define_models :users
      
      def act!; get :index, :format => 'xml' ; end

      it "assigns collections" do
        act!
        assigns[:collections].should_not be_nil
      end
      #it_renders :xml, :collections
      #it "renders xml" do
      #  act!
        #response.format.should be_xml
      #end
    end

    describe Tool::CollectionsController, "(json)" do
      #define_models :users
      
      def act!; get :index, :format => 'json' ; end

      it "assigns collections" do
        act!
        assigns[:collections].should_not be_nil
      end
      #it_renders :json, :collections
      it "renders json" do
        act!
        #response.format.should be_json
      end
    end

  
  end

  describe Tool::CollectionsController, "GET #show" do
    #define_models :users

    def act!; get :show, :id => 1 ; end

    before do
      @collection  = collections(:default)
      Tool::Collection.stub!(:find).with('1').and_return(@collection)
    end
    
    #it_assigns :collection
      it "assigns collection" do
        act!
        assigns[:collection].should_not be_nil
      end
    #it_renders :template, :show
    it "renders the show template" do
      act!
      response.should render_template( :show )
    end
    
    describe Tool::CollectionsController, "(xml)" do
      #define_models :users
      
      def act!; get :show, :id => 1, :format => 'xml' ; end

      #it_renders :xml, :collection
      it "renders xml" do
        act!
        #response.format.should be_xml
      end
    
    end

    describe Tool::CollectionsController, "(json)" do
      #define_models :users
      
      def act!; get :show, :id => 1, :format => 'json' ; end

      #it_renders :json, :collection
      it "renders json" do
        act!
        #response.format.should be_json
      end
    end

  
  end

  describe Tool::CollectionsController, "GET #new" do
    #define_models :users
    def act!; get :new ; end
    before do
      @collection  = Tool::Collection.new
    end

    it "assigns @collection" do
      act!
      assigns[:collection].should be_new_record
    end
    
    #it_renders :template, :new
    it "renders the new template" do
      act!
      response.should render_template(:new)
    end
    
    
    describe Tool::CollectionsController, "(xml)" do
      #define_models :users
      def act!; get :new, :format => 'xml' ; end

      #it_renders :xml, :collection
      it "renders xml" do
        act!
        #response.format.should be_xml
      end
    end

    describe Tool::CollectionsController, "(json)" do
      #define_models :users
      def act!; get :new, :format => 'json' ; end

      #it_renders :json, :collection
      it "renders json" do
        act!
        #response.format.should be_json
      end
    end

  
  end

  describe Tool::CollectionsController, "GET #edit" do
    #define_models :users
    def act!; get :edit, :id => 1 ; end
    
    before do
      @collection  = collections(:default)
      Tool::Collection.stub!(:find).with('1').and_return(@collection)
    end

    #it_assigns :collection
    it "assigns @collection" do
      act!
      assigns[:collection].should_not be_nil
    end
    
    #it_renders :template, :edit
    it "renders the edit template" do
      act!
      response.should render_template(:edit)
    end
    
  end

  describe Tool::CollectionsController, "POST #create" do
    before do
      @attributes = {}
      @collection = mock_model Tool::Collection, :new_record? => false, :errors => [], :name => ""
      Tool::Collection.stub!(:new).with(@attributes).and_return(@collection)
    end
    
    describe Tool::CollectionsController, "(successful creation)" do
      #define_models :users
      def act!; post :create, :collection => @attributes ; end

      before do
        @collection.stub!(:save).and_return(true)
      end
      
      #it_assigns :collection, :flash => { :notice => :not_nil }
      it "assigns @collection" do
        act!
        assigns[:collection].should_not be_nil
      end
      it "assigns flash" do
        act!
        flash[:notice].should_not be_nil
      end
    
      #it_redirects_to { collection_path(@collection) }
      it "redirects to new collection" do
        act!
        response.should redirect_to( :controller => 'collections', :id => @collection.id ) 
      end
    end

    describe Tool::CollectionsController, "(unsuccessful creation)" do
      #define_models :users
      def act!; post :create, :collection => @attributes ; end

      before do
        @collection.stub!(:save).and_return(false)
      end
      
      #it_assigns :collection
      it "assigns @collection" do
        act!
        assigns[:collection].should_not be_nil
      end
    
      #it_renders :template, :new
      it "renders the new template" do
        act!
        response.should render_template(:new)
      end
    
    end
    
    describe Tool::CollectionsController, "(successful creation, xml)" do
      #define_models :users
      def act!; post :create, :collection => @attributes, :format => 'xml' ; end

      before do
        @collection.stub!(:save).and_return(true)
        @collection.stub!(:to_xml).and_return("mocked content")
      end
      
      #it_assigns :collection, :headers => { :Location => lambda { collection_url(@collection) } }
      it "assigns @collection" do
        act!
        assigns[:collection].should_not be_nil
      end
    
      #it_renders :xml, :collection, :status => :created
#      it "renders xml" do
#        act!
#        response.body.should match( collection.to_xml )
#        response.status.should be_created
#      end
    end
    
    describe Tool::CollectionsController, "(unsuccessful creation, xml)" do
      #define_models :users
      def act!; post :create, :collection => @attributes, :format => 'xml' ; end

      before do
        @collection.stub!(:save).and_return(false)
      end
      
      #it_assigns :collection
      it "assigns @collection" do
        act!
        assigns[:collection].should_not be_nil
      end
    
#      #it_renders :xml, "collection.errors", :status => :unprocessable_entity
#      it "renders xml" do
#        act!
#        response.status.should be_unprocessable_entity
#      end
    end

    describe Tool::CollectionsController, "(successful creation, json)" do
      #define_models :users
      def act!; post :create, :collection => @attributes, :format => 'json' ; end

      before do
        @collection.stub!(:save).and_return(true)
        @collection.stub!(:to_json).and_return("mocked content")
      end
      
      #it_assigns :collection, :headers => { :Location => lambda { collection_url(@collection) } }
      it "assigns @collection" do
        act!
        assigns[:collection].should_not be_nil
      end
    
#      #it_renders :json, :collection, :status => :created
#      it "renders json" do
#        act!
#        #response.format.should be_json
#        response.status.should be_created
#      end
    end
    
    describe Tool::CollectionsController, "(unsuccessful creation, json)" do
      #define_models :users
      def act!; post :create, :collection => @attributes, :format => 'json' ; end

      before do
        @collection.stub!(:save).and_return(false)
      end
      
      #it_assigns :collection
      it "assigns @collection" do
        act!
        assigns[:collection].should_not be_nil
      end
    
#      #it_renders :json, "collection.errors", :status => :unprocessable_entity
#      it "renders json" do
#        act!
#        #response.format.should be_json
#        response.status.should be_unprocessable_entity
#      end
    end

  end

  describe Tool::CollectionsController, "PUT #update" do
    before do
      @attributes = {}
      @collection = collections(:default)
      Tool::Collection.stub!(:find).with('1').and_return(@collection)
    end
    
    describe Tool::CollectionsController, "(successful save)" do
      #define_models :users
      def act!; put :update, :id => 1, :collection => @attributes ; end

      before do
        @collection.stub!(:save).and_return(true)
      end
      
      #it_assigns :collection, :flash => { :notice => :not_nil }
      it "assigns @collection" do
        act!
        assigns[:collection].should_not be_nil
      end
      it "assigns flash" do
        act!
        flash[:notice].should_not be_nil
      end
    
      #it_redirects_to { collection_path(@collection) }
      it "redirects to saved item" do
        act!
        response.should redirect_to( :controller => 'collections', :id => @collection.id ) 
      end
    end

    describe Tool::CollectionsController, "(unsuccessful save)" do
      #define_models :users
      def act!; put :update, :id => 1, :collection => @attributes ; end

      before do
        @collection.stub!(:save).and_return(false)
      end
      
      #it_assigns :collection
      it "assigns @collection" do
        act!
        assigns[:collection].should_not be_nil
      end
    
      #it_renders :template, :edit
      it "renders the edit template" do
        act!
        response.should render_template(:edit)
      end
    
    end
    
    describe Tool::CollectionsController, "(successful save, xml)" do
      #define_models :users
      def act!; put :update, :id => 1, :collection => @attributes, :format => 'xml' ; end

      before do
        @collection.stub!(:save).and_return(true)
      end
      
      #it_assigns :collection
      it "assigns @collection" do
        act!
        assigns[:collection].should_not be_nil
      end
    
      #it_renders :blank
      it "is blank" do
        act!
        response.body.should be_blank
      end
    end
    
    describe Tool::CollectionsController, "(unsuccessful save, xml)" do
      #define_models :users
      def act!; put :update, :id => 1, :collection => @attributes, :format => 'xml' ; end

      before do
        @collection.stub!(:save).and_return(false)
      end
      
      #it_assigns :collection
      it "assigns @collection" do
        act!
        assigns[:collection].should_not be_nil
      end
    
      #it_renders :xml, "collection.errors", :status => :unprocessable_entity
      it "renders xml" do
        #act!
        #response.format.should be_xml
        
      end
    end

    describe Tool::CollectionsController, "(successful save, json)" do
      #define_models :users
      def act!; put :update, :id => 1, :collection => @attributes, :format => 'json' ; end

      before do
        @collection.stub!(:save).and_return(true)
      end
      
      #it_assigns :collection
      it "assigns @collection" do
        act!
        assigns[:collection].should_not be_nil
      end
    
      #it_renders :blank
      it "is blank" do
        act!
        response.body.should be_blank
      end
    end
    
    describe Tool::CollectionsController, "(unsuccessful save, json)" do
      #define_models :users
      def act!; put :update, :id => 1, :collection => @attributes, :format => 'json' ; end

      before do
        @collection.stub!(:save).and_return(false)
      end
      
      #it_assigns :collection
      it "assigns @collection" do
        act!
        assigns[:collection].should_not be_nil
      end
    
      #it_renders :json, "collection.errors", :status => :unprocessable_entity
#      it "renders json" do
#        act!
#        #response.send(:format).should be_json
#        #response.status.should be_unprocessable_entity
#      end
    end

  end

  describe Tool::CollectionsController, "DELETE #destroy" do

    def act!; delete :destroy, :id => 1 ; end
    
    before do
      @collection = collections(:default)
      @collection.stub!(:destroy)
      Tool::Collection.stub!(:find).with('1').and_return(@collection)
    end

    #it_assigns :collection
    it "assigns @collection" do
      act!
      assigns[:collection].should_not be_nil
    end
    
    #it_redirects_to { collections_path }
    it "redirects to collections" do
      act!
      response.should redirect_to( :controller => 'collections', :action => 'index' )
    end
    
    describe Tool::CollectionsController, "(xml)" do
      #define_models :users
      def act!; delete :destroy, :id => 1, :format => 'xml' ; end

      #it_assigns :collection
      it "assigns @collection" do
        act!
        assigns[:collection].should_not be_nil
      end
    
      #it_renders :blank
      it "is blank" do
        act!
        response.body.should be_blank
      end
    end

    describe Tool::CollectionsController, "(json)" do
      #define_models :users
      def act!; delete :destroy, :id => 1, :format => 'json' ; end

      #it_assigns :collection
      it "assigns @collection" do
        act!
        assigns[:collection].should_not be_nil
      end
    
      #it_renders :blank
      it "is blank" do
        act!
        response.body.should be_blank
      end
    end

  
  end
end
