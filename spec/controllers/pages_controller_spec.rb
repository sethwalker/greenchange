require File.dirname(__FILE__) + '/../spec_helper'

describe PagesController do
  describe "create" do
    before do
      login_user create_user
      get :create
    end
    it "should be success" do
      response.should be_success
    end
    it "should render template create" do
      response.should render_template('pages/create')
    end
  end

  describe "protected methods" do
    before do
      @page = create_page
    end
    [:tag, :notify, :access, :move, :destroy].each do |action|
      it "should require login for #{action.to_s}" do
        lambda {get action, :id => @page.id}.should require_login
      end
    end
  end

  describe "when saving tags" do
    before do
      stub_login
      disable_filters
    end

    it "should call tag_with with some tags" do
      tags = "tag1 tag2 tag3"
      page = usable_page_stub 
      page.should_receive(:tag_with).with(tags)
      Page.stub!(:find_by_id).and_return(page)
      xhr :post, :tag, :id => '111', :tag_list => "tag1 tag2 tag3"
    end

    it "should call save on the Tag" do
      page = usable_page_stub
      Page.stub!(:find_by_id).and_return(page)
      page.should_receive(:save)
      xhr :post, :tag, :id => '111', :tag_list => "tag1 tag2 tag3"
    end

    it "should render the pages _tags partial" do
      page = usable_page_stub
      Page.stub!(:find_by_id).and_return(page)
      controller.should_receive(:render).with(:partial => 'pages/tags') 
      xhr :post, :tag, :id => '111', :tag_list => "tag1 tag2 tag3"
    end
  end

  describe "archive" do
    before do
      @group = create_group
      pending "renew support for page archives view"
    end

    describe "when allowed" do
      describe "archive" do
        before do
          get :archive, :group_id => @group.name
        end
        it "should render archive" do
          get :archive, :group_id => @group.name
          response.should render_template('pages/archive')
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

  def disable_filters
    controller.stub!(:context)
    controller.stub!(:authorized?).and_return(true)
  end

  def usable_page_stub
    returning mock_model(Page) do |page|
      page.stub!(:participation_for_user)
      page.stub!(:tag_with)
      page.stub!(:save)
    end
  end

      
  def stub_login
    @user = mock_model(User)
    @user.stub!(:banner_style)
    @user.stub!(:time_zone)
    yield @user if block_given?
    controller.stub!(:current_user).and_return(@user)
    controller.stub!(:logged_in?).and_return(true)
  end
end
