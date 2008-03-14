require File.dirname(__FILE__) + '/../spec_helper'

describe Group do

  describe "with recent discussions" do
    before do
      g = Group.create! :name => 'group'
      g.pages << (@p1 = Page.create! :title => 'page1', :public => true, :group_id => g.id)
      g.pages << (@p2 = Page.create! :title => 'page2', :public => true, :group_id => g.id)
      g.pages << (@p3 = Page.create! :title => 'page3', :public => true, :group_id => g.id)
      d1 = @p1.create_discussion
      d2 = @p2.create_discussion
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

      @g = Group.find(g)
      @recently_commented = @g.pages.find(:all, :include => {:discussion => :posts}, :conditions => "posts.id", :order => "posts.created_at")
    end

    it "should return the proper recently commented pages" do
      @recently_commented.length.should == 2
    end

    it "should include the recently commented pages in the returned array" do
      @recently_commented.should include(@p1)
      @recently_commented.should include(@p2)
    end

    it "should not include a non recently commented page" do
      @recently_commented.should_not include(@p3)
    end
  end
end
