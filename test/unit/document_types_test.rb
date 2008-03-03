require File.dirname(__FILE__) + '/../test_helper'
class DocumentTypesTest < Test::Unit::TestCase
  def setup
    @controller = PagesController.new
    @controller.stubs(:current_user).returns(User.new)
    @controller.stubs(:logged_in?).returns(true)
    @controller.stubs(:params).returns({})
  end

  # Replace this with your real tests.
  def test_find_pages
    news = Tool::News.create :title => 'newsish title', :public => true
    blog = Tool::Blog.create :title => 'blogish title', :public => true
    alert = Tool::ActionAlert.create :title => 'action alertish title', :public => true

    pages = Page.find_by_path('/type/news/or/type/blog', @controller.options_for_public_pages)
    page_ids = pages.map(&:id)
    assert page_ids.include?(news.id)
    assert page_ids.include?(blog.id)
    assert !page_ids.include?(alert.id)
  end

  def test_find_action_alerts
    news = Tool::News.create :title => 'newsish title', :public => true
    alert = Tool::ActionAlert.create :title => 'action alertish title', :public => true
    pages = Page.find_by_path('/type/action_alert/or/type/news', @controller.options_for_public_pages)
    page_ids = pages.map(&:id)
    assert page_ids.include?(news.id)
    assert page_ids.include?(alert.id)
  end

  def test_find_pages_for_group
    g = Group.create :name => 'haspages'
    news = Tool::News.create :title => 'newsish title', :public => true, :group_id => g.id
    blog = Tool::Blog.create :title => 'blogish title', :public => true, :group_id => g.id
    news.add(g)
    blog.add(g)
    # apparently in this case, find_pages actually returns GroupParticipation array.  unexpected.
    pages = Page.find_by_path('/type/news/or/type/blog', @controller.options_for_group(g))
    page_ids = pages.map(&:id)
    assert page_ids.include?(news.id)
    assert page_ids.include?(blog.id)
  end
end
