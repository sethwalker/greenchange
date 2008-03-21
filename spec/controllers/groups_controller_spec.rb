require File.dirname(__FILE__) + '/../spec_helper'

describe GroupsController do
  describe "create" do
    before do
      @user = User.new
      controller.stub!(:current_user).and_return(@user)
    end
    it "should not respond to GET" do
      get :create
      response.should_not be_success
    end

    it "should respond to POST" do
      controller.should_receive(:message)
      g = Group.new
      g.should_receive(:save).and_return(false)
      Group.should_receive(:new).and_return(g)
      post :create
      response.should be_success
    end

    it "should clear parent groups users cache after create" do
      parent = create_valid_group :name => 'daparent'
      @user.stub!(:member_of?).and_return(true)
      post :create, :parent_id => parent.id, :group => {:name => 'dacommittee'}
    end
  end
  describe "archive" do
    before do
      @group = create_valid_group
    end
    describe "when logged in" do
      before do
        @group.pages << create_valid_page
        @user = create_valid_user
      end

      describe "when a member" do
        before do
          @group.memberships.create(:user => @user)
          @user.stub!(:member_of?).and_return(true)
          @group.stub!(:allows?).and_return(true)
          Group.stub!(:get_by_name).and_return(@group)
          controller.stub!(:current_user).and_return(@user)
        end
        def act
          get :archive, :id => @group.name
        end
        it "should not redirect" do
          act
          response.should_not be_redirect
        end
        it "should be successful" do
          act
          response.should be_success
        end
        it "should render archive template" do
          act
          response.should render_template('groups/archive')
        end
        it "should have a valid group" do
          act
          assigns[:group].should be_valid
        end
        it "months should not be nil" do
          act
          assigns[:months].should_not be_nil
        end
      end

      describe "when a public group" do
        before do
          @group.profile.may_see = true
          @group.profile.save
          get :archive, :id => @group.name
        end
        it "should be successful" do
          response.should be_success
        end
        it "should render archive template" do
          response.should render_template('groups/archive')
        end
        it "should have a valid group" do
          assigns[:group].should be_valid
        end
        it "months should not be nil" do
          assigns[:months].should_not be_nil
        end
      end

      describe "when a private group" do
        before do
          @group.profile.may_see = false
          @group.profile.save
          get :archive, :id => @group.name
        end
        it "should render show_nothing" do
          response.should render_template('groups/show_nothing')
        end
      end
    end
    describe "when not logged in" do
      it "should be sucess for a public group" do
        @group.profile.may_see = true
        @group.profile.save
        get :archive, :id => @group.name
        response.should render_template('groups/archive')
      end
      it "should show nothing for a private group" do
        @group.profile.may_see = false
        @group.profile.save
        get :archive, :id => @group.name
        response.should render_template('groups/show_nothing')
      end
    end

    describe "when allowed" do
      before do
        @user = create_valid_user
        @group.memberships.create(:user => @user)
        controller.stub!(:current_user).and_return(@user)
        @group.pages << (p1 = create_valid_page(:created_at => Date.new(2007, 12)))
        @group.pages << (p2 = create_valid_page(:created_at => Date.new(2008, 2)))
        @group.member_collection << p1
        @group.member_collection << p2
        @group.should_receive(:allows?).any_number_of_times.and_return(true)
        Group.stub!(:get_by_name).and_return(@group)
      end
      describe "archive" do
        before do
          get :archive, :id => @group.name
        end
        it "should render archive" do
          get :archive, :id => @group.name
          response.should render_template('groups/archive')
        end
        it "should populate months with the months and years pages were created" do
          assigns[:months].length.should == 2
        end
        it "should populate months with the months and years pages were created" do
          assigns[:months][0]['month'].should == '12'
          assigns[:months][0]['year'].should == '2007'
        end
        it "should populate months with the months and years pages were created" do
          assigns[:months][1]['month'].should == '2'
          assigns[:months][1]['year'].should == '2008'
        end
        it "should populate pages with a paginated collection" do
          assigns[:pages].should_not be_empty
          assigns[:pages].all? {|p| p.created_at.year == 2008}.should be_true
        end
      end
    end
  end

  describe "tasks" do
    before do
      @group = create_valid_group
      @user = create_valid_user
      controller.stub!(:current_user).and_return(@user)
    end
    it "should be successful" do
      get :tasks, :id => @group.name
      response.should be_success
    end
  end

  describe "tags" do
    before do
      user = login_valid_user 
      @group = create_valid_group
      @group.memberships.create :user => user
      @page = create_valid_page
      @page.tag_with 'tagish'
      @group.pages << @page
      @group.member_collection << @page
    end
    it "should not die" do
      get :tags, :id => @group.name, :path => ['tagish']
      assigns[:pages].should include(@page)
    end
    it "should be a paginated collection" do
      get :tags, :id => @group.name, :path => ['tagish']
      assigns[:pages].should be_a_kind_of(WillPaginate::Collection)
    end
  end
end



#from functional test
describe GroupsController do
  before do
    @group = create_group(:name => 'rainbow')
  end
  describe "when logged in" do
    before do
      @user = create_valid_user
      login_user @user
    end

    describe "index" do
      before { get :index }
      it "should be success" do
        assert_response :success
      end
      it "should render list template" do
        assert_template 'list'
      end
    end

    describe "list" do
      before { get :list }

      it "should be success" do
        assert_response :success
      end
      it "should render list template" do
        assert_template 'list'
      end
      it "should set @groups" do
        assert_not_nil assigns[:groups]
      end
    end

    describe "show" do
      before do
        @group.should_receive(:allows?).and_return(true)
        Group.stub!(:get_by_name).and_return(@group)
        get :show, :id => @group.name
      end

      it "should be success" do
        assert_response :success
      end
      it "should render template show" do
        assert_template 'show'
      end
      it "should set @group" do
        assert_not_nil assigns[:group]
      end
      it "@group should be valid" do
        assert assigns[:group].valid?
      end
    end

    describe "new" do
      before do
        get :new
      end
      it "should be success" do
        assert_response :success
      end
      it "should render template new" do
        assert_template 'new'
      end
    end

    describe "create" do
      before { post :create, :group => {:name => 'test-create-group'} }

      it "should redirect" do
        assert_response :redirect
      end
      it "should redirect to the groups url" do
        assert_redirected_to controller.url_for_group(assigns[:group], :action => 'show')
      end
      it "should create group" do
        assert_equal assigns[:group].name, 'test-create-group'
      end
    end
    
    describe "edit" do
      before do
        @group.should_receive(:allows?).with(@user, 'edit').and_return(true)
        Group.stub!(:get_by_name).and_return(@group)
        get :edit, :id => @group.name
      end

      it "should be success" do
        assert_response :success
      end
      it "should render template edit" do
        assert_template 'edit'
      end
      it "should set @group" do
        assert_not_nil assigns[:group]
      end
      it "@group should be valid" do
        assert assigns[:group].valid?
      end
    end

    describe "update" do
      before do
        @group.should_receive(:allows?).with(@user, 'update').and_return(true)
        Group.stub!(:get_by_name).and_return(@group)
        post :update, :id => @group.name
      end
      it "should be redirect" do
        assert_response :redirect
      end
      it "should be redirected to show" do
        assert_redirected_to :action => 'show', :id => @group.name
      end
    end

    describe "destroy" do
      before do
        @group.memberships.create(:user => @user)
        @group.should_receive(:allows?).with(@user, 'destroy').and_return(true)
        Group.should_receive(:get_by_name).with(@group.name).and_return(@group)
        post :destroy, :id => @group.name 
      end
      it "should be destroyed" do
        lambda { Group.find @group.id }.should raise_error(ActiveRecord::RecordNotFound)
      end
      it "should redirect to list" do
        assert_redirected_to :action => 'list'    
      end
    end

    it "should get blog" do
      @group.pages << (page = Tool::Blog.create(:title => 'a blog'))
      lambda { get :blog, :id => @group.name }.should_not raise_error
    end

    it "should get events" do
      @group.pages << (page = Tool::Event.create( :title => 'arts nite', :starts_at => 1.day.from_now, :ends_at => (1.day + 1.hour).from_now))
      lambda { get :events, :id => @group.name}.should_not raise_error
    end
  end

  describe "when not logged in" do
    describe "show" do
      before do
        @group.name = 'private'
        @group.should_receive(:allows?).with(an_instance_of(UnauthenticatedUser), :view).and_return(false)
        Group.should_receive(:get_by_name).and_return(@group)
        get :show, :id => @group.name
      end
      it "should be success" do
        assert_response :success
      end
      it "should render show_nothing" do
        assert_template 'show_nothing'
      end
    end

    describe "when accessing protected methods" do
      [:create, :edit, :destroy, :update].each do |action|
        it "should require login for #{action.to_s}" do
          lambda { get action, :id => @group.name }.should require_login
        end
      end
    end
  end
end
