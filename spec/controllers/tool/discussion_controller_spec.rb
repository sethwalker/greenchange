require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/shared'

describe Tool::DiscussionController do
  it_should_behave_like "a tool controller"

  describe "create" do
    before do
      login_user(@user = new_user)
      post :create, :page => {:title => 'thetitle'}
    end
    it "should make a discussion" do
      assigns[:page].should be_a_kind_of(Tool::Discussion)
    end
    it "should redirect_to discussion_url" do
      response.should redirect_to(discussion_url(assigns[:page]))
    end
  end
end

describe Tool::DiscussionController do
  describe "when displaying a page" do
    integrate_views
    before do
      discussion = Discussion.create
      60.times do 
        p = Post.new :body => 'post'
        p.stub!(:group_name).and_return('grouple')
        p.user_id = 1
        p.discussion = discussion
        p.save_with_validation(false)
      end
      page = stub_everything('page')
      page.stub!(:created_at).and_return(Time.now)
      page.should_receive(:discussion).any_number_of_times.and_return(discussion)
      page.should_receive(:data).any_number_of_times.and_return(discussion)
      Tool::Discussion.should_receive(:find).and_return(page)
      controller.stub!(:login_or_public_page_required).and_return(true)
      controller.stub_render('posts/_post')
    end

    it "shows show page" do
      get 'show', :id => 'mock'
      response.should_not be_redirect
      response.should render_template('tool/discussion/show')
    end

    it "paginates posts correctly" do
      pending "test creates malformed output, unknown reason"
      get 'show', :id => 'mock'
      response.should have_tag('div.pagination')
    end
    
    it "continues to paginate posts correctly" do
      pending "test creates malformed output, unknown reason"
      get 'show', :id => 'mock', :posts => 2
      response.should have_tag('div.pagination')
    end
  end
end
