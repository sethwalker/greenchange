require File.dirname(__FILE__) + '/../../spec_helper'
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
      page.should_receive(:discussion).any_number_of_times.and_return(discussion)
      Page.should_receive(:find).and_return(page)
      controller.stub!(:login_or_public_page_required).and_return(true)
      controller.stub!(:page_context)
      controller.stub_render('posts/_post')
    end

    it "shows show page" do
      get 'show', :page_id => 'mock'
      response.should render_template('tool/discussion/show')
    end

    it "paginates posts correctly" do
      get 'show', :page_id => 'mock'
      response.should have_tag('div.pagination')
    end
    
    it "continues to paginate posts correctly" do
      get 'show', :page_id => 'mock', :posts => 2
      response.should have_tag('div.pagination')
    end
  end
end
