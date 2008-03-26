require File.dirname(__FILE__) + '/../spec_helper'

describe Group do

  before do
    @g = Group.create :name => 'fruits'
  end

  describe "with members" do
    before do
      @u = create_user(:login => 'blue')
    end

    it "should raise an error when using << (WHY???)" do
      lambda { @g.users << @u }.should raise_error
    end

    it "member_of? should return true if member" do
      @g.memberships.create :user => @u, :role => :member
      @u.should be_a_member_of(@g)
    end

    it "should call membership_changed when membership is created" do
      @g.should_receive(:membership_changed)
      @g.memberships.create :user => @u, :role => :member
    end
  end

  it "should require a name" do
    g = Group.create
    g.should have_at_least(1).error_on(:name)
  end

  it "should have a unique name" do
    g2 = new_group(:name => 'fruits')
    g2.save
    g2.should have(1).error_on(:name)
  end
end

describe Group do
  before do
    User.current = nil
    @group = Group.new :name => 'banditos_for_bush'
  end

  it "should have the same tags as its pages" do
    @page = create_valid_page
    @group.save!
    @group.pages << @page
    @page.tag_with 'crackers ninjas'
    @group.tags.map(&:name).should include('ninjas')
  end

  describe "months_with_pages_viewable_by_user" do
    describe "when checking the connection adapter" do
      it "recognizes sqlite" do
        Page.stub!(:connection).and_return(connection = stub('connection', :adapter_name => 'SQLite'))
        connection.should_receive(:select_all).with(%r{SELECT #{Regexp.escape(@group.sqlite_months_string)}})
        @group.months_with_pages_viewable_by_user(User.new)

      end
      it "recognizes mysql" do
        Page.stub!(:connection).and_return(connection = stub('connection', :adapter_name => 'MySQL'))
        connection.should_receive(:select_all).with(%r{SELECT #{Regexp.escape(@group.mysql_months_string)}})
        @group.months_with_pages_viewable_by_user(User.new)
      end
    end
    it "returns proper months" do
      @group.save
      @group.pages << create_valid_page(:created_at => Date.new(2007, 12))
      @group.pages << create_valid_page(:created_at => Date.new(2008, 2))
      @group.stub!(:allows?).and_return(true)
      months = @group.months_with_pages_viewable_by_user(User.new)
      months[0]['month'].should == '12'
      months[1]['year'].should == '2008'
    end
  end

end

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
