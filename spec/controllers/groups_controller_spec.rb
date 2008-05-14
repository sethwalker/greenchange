require File.dirname(__FILE__) + '/../spec_helper'

describe GroupsController do

  describe "create" do
    before do
      @user = User.new
      controller.stub!(:current_user).and_return(@user)
    end

    it "should respond to POST" do
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

#  describe "tasks" do
#    before do
#      @group = create_valid_group
#      @user = create_valid_user
#      controller.stub!(:current_user).and_return(@user)
#    end
#    it "should be successful" do
#      get :tasks, :id => @group.name
#      response.should be_success
#    end
#  end
#
#  describe "tags" do
#    before do
#      user = login_valid_user 
#      @group = create_valid_group
#      @group.memberships.create :user => user
#      @page = create_valid_page
#      @page.tag_with 'tagish'
#      @group.pages << @page
#      @group.member_collection << @page
#    end
#    it "should not die" do
#      get :tags, :id => @group.name, :path => ['tagish']
#      assigns[:pages].should include(@page)
#    end
#    it "should be a paginated collection" do
#      get :tags, :id => @group.name, :path => ['tagish']
#      assigns[:pages].should be_a_kind_of(WillPaginate::Collection)
#    end
#  end

  describe "group calendar" do
    before do
      @group = create_valid_group
      @page = Tool::Event.create :title => 'anevent', :group_id => @group.id
    end
    describe "list_by_day" do
      it "should be successful" do
        get :list_by_day, :id => @group.to_param
        response.should be_success
      end
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
        assert_template 'index'
      end
    end

    describe "show" do
      before do
        #@group.should_receive(:allows?).and_return(true)
        Group.stub!(:find_by_name).and_return(@group)
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
        assert_redirected_to group_url(assigns[:group])
      end
      it "should create group" do
        assert_equal assigns[:group].name, 'test-create-group'
      end
    end
    
    describe "edit" do
      before do
        @group.stub!(:allows?).and_return(true)
        Group.stub!(:find_by_name).and_return(@group)
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
        @group.stub!(:allows?).and_return(true)
        Group.stub!(:find_by_name).and_return(@group)
        post :update, :id => @group
      end
      it "checks permissions" do
        @group.should_receive(:allows?).and_return(true)
        post :update, :id => @group
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
        @group.stub!(:allows?).and_return(true)
        Group.stub!(:find_by_name).and_return(@group)
        post :destroy, :id => @group.to_param
      end
      it "checks permissions" do
        @group.should_receive(:allows?).at_least(1).times.and_return(true)
        post :destroy, :id => @group.to_param
      end
      it "should redirect to list" do
        response.should redirect_to( groups_path )
      end
    end
    describe "invalid record" do
      it "should be destroyed" do
        lambda { post :destroy, :id => 'bad-data' }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end

#    it "should get blog" do
#      @group.pages << (page = Tool::Blog.create(:title => 'a blog'))
#      lambda { get :blog, :id => @group.name }.should_not raise_error
#    end

  end

  describe "when not logged in" do
    before do
        @group = create_valid_group :name => 'private'
    end
    describe "show" do
      before do
        @group.stub!(:allows?).with(an_instance_of(UnauthenticatedUser), :view).and_return(false)
        Group.stub!(:find_by_name).and_return(@group)
        get :show, :id => @group.name
      end
      it "should be success" do
        response.should be_success
      end
      it "should render show_nothing" do
        pending 're-enable the private groups feature?'
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
