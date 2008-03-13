require File.dirname(__FILE__) + '/../spec_helper'

describe "Document Types" do

  before do
    @controller = PagesController.new
    @controller.stub!(:current_user).and_return(User.new)
    @controller.stub!(:logged_in?).and_return(true)
    @controller.stub!(:params).and_return({})
  end

  # Replace this with your real tests.
  describe "when finding news and blogs" do
    before do
      @news = Tool::News.create :title => 'newsish title', :public => true
      @blog = Tool::Blog.create :title => 'blogish title', :public => true
      @alert = Tool::ActionAlert.create :title => 'action alertish title', :public => true

      pages = Page.find_by_path('/type/news/or/type/blog', @controller.options_for_public_pages)
      @page_ids = pages.map(&:id)
    end

    it "should find news" do
      @page_ids.should include(@news.id)
    end

    it "should find blog" do
      @page_ids.should include(@blog.id)
    end

    it "should not find alert" do
      @page_ids.should_not include(@alert.id)
    end
  end

  describe "when finding actions and news" do
    before do
      @news = Tool::News.create :title => 'newsish title', :public => true
      @alert = Tool::ActionAlert.create :title => 'action alertish title', :public => true
      pages = Page.find_by_path('/type/action_alert/or/type/news', @controller.options_for_public_pages)
      @page_ids = pages.map(&:id)
    end

    it "should find news" do
      @page_ids.should include(@news.id)
    end
    it "should find alerts" do
      @page_ids.should include(@alert.id)
    end
  end

  describe "when finding pages for a group" do
    before do
      g = Group.create! :name => 'haspages'
      @news = Tool::News.create :title => 'newsish title', :public => true, :group_id => g.id
      @blog = Tool::Blog.create :title => 'blogish title', :public => true, :group_id => g.id
      @news.add(g)
      @blog.add(g)
      # apparently in this case, find_pages actually returns GroupParticipation array.  unexpected.
      pages = Page.find_by_path('/type/news/or/type/blog', @controller.options_for_group(g))
      @page_ids = pages.map(&:id)
    end

    it "should find news" do
      @page_ids.should include(@news.id)
    end
    it "should find blog" do
      @page_ids.should include(@blog.id)
    end
  end
end
