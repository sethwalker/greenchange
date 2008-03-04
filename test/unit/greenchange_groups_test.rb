require File.dirname(__FILE__) + '/../test_helper'

class GreenchangeGroupsTest < Test::Unit::TestCase

  def test_group_recent_discussions
    g = Group.create! :name => 'group'
    g.pages << (p1 = Page.create! :title => 'page1', :public => true, :group_id => g.id)
    g.pages << (p2 = Page.create! :title => 'page2', :public => true, :group_id => g.id)
    g.pages << (p3 = Page.create! :title => 'page3', :public => true, :group_id => g.id)
    d1 = p1.create_discussion
    d2 = p2.create_discussion
    post = Post.new(:body => 'first post on page 1')
    post.user_id = 1
    post.discussion = d1
    post.save!

    post = Post.new(:body => 'first post on page 2')
    post.user_id = 1
    post.discussion = d2
    post.save!

    post = Post.new(:body => 'second post on page 1')
    post.user_id = 1
    post.discussion = d1
    post.save!

    g = Group.find(g)
    assert_equal 3, g.pages.length
    recently_commented = g.pages.find(:all, :include => {:discussion => :posts}, :conditions => "posts.id", :order => "posts.created_at")
    assert_equal 2, recently_commented.length
    assert recently_commented.include?(p1)
    assert recently_commented.include?(p2)
    assert !recently_commented.include?(p3)
  end
end
