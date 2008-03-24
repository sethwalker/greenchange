require File.dirname(__FILE__) + '/../spec_helper'

describe Page do

  before do
    User.current = nil
    @page = Page.new :title => 'this is a very fine test page'
    User.current = nil
  end

  it "should make a friendly url from a nameized title and id" do
    @page.stub!(:id).and_return('111')
    @page.friendly_url.should == 'this-is-a-very-fine-test-page+111'
  end

  it "should not consider the unique name taken if it's not" do
    @page.stub!(:name).and_return('a page name')
    Page.stub!(:find).and_return(nil)
    @page.name_taken?.should == false
  end

  it "should not consider the unique name taken if it's our own" do
    @page.stub!(:name).and_return('a page name')
    Page.stub!(:find).and_return(@page)
    @page.name_taken?.should == false
  end

  it "should consider name taken if another page has this name in the group namespace" do
    @page.stub!(:name).and_return('a page name')
    Page.stub!(:find).and_return(stub(:name => 'a page name'))
    @page.name_taken?.should == true
  end

  it "should allow a unique name to be nil" do
    @page.name = nil
    @page.should be_valid
  end

  it "should not allow a one letter unique name" do
    @page.name = "x"
    @page.should_not be_valid
  end

  it "should not be valid if the name has changed to an existing name" do
    @page.stub!(:name_modified?).and_return(true)
    @page.stub!(:name_taken?).and_return(true)
    @page.should_not be_valid
    @page.should have(1).error_on(:name)
  end

  it "should resolve user participations when resolving" do
    up1 = mock_model( UserParticipation, :resolved= => nil, :save => nil )
    up2 = mock_model( UserParticipation, :resolved= => nil, :save => nil )
    up1.should_receive(:resolved=).with( true)
    up2.should_receive(:resolved=).with( true)
    @page.stub!(:user_participations).and_return([up1, up2])
    @page.should_receive(:save)
    @page.should_receive(:resolved=)
    @page.resolve
  end

  it "should unresolve user participations when unresolving" do
    up1 = mock_model( UserParticipation, :resolved= => nil, :save => nil )
    up2 = mock_model( UserParticipation, :resolved= => nil, :save => nil )
    up1.should_receive(:resolved=).with(false)
    up2.should_receive(:resolved=).with(false)
    @page.stub!(:user_participations).and_return([up1, up2])
    @page.should_receive(:resolved=).with(false)
    @page.unresolve
  end

  describe "when saving tags" do
    it "accepts tag_with calls" do
      @page.should respond_to(:tag_with)
    end
    it "gives back the tags we give it" do
      @page.save
      @page.tag_with( "noodles soup")
      @page.tag_list.should include("noodles")
    end
    it "read tags with tag_list" do
      @page.save
      @page.tag_with "noodles soup"
      @page.tag_list.should include("soup")
    end
  end

  it "should respond to bookmarks" do
    p = Page.new
    p.should respond_to(:bookmarks)
  end

  it "has_finder for month returns pages" do
    p = create_valid_page(:created_at => Date.new(2008, 2))
    pages = Page.created_in_month('2')
    pages.should_not be_empty
  end

  it "has_finder for year returns pages" do
    p = create_valid_page(:created_at => Date.new(2008, 2))
    pages = Page.created_in_year('2008')
    pages.should_not be_empty
  end

  it "has_finder for month and year returns pages" do
    p = create_valid_page(:created_at => Date.new(2008, 2))
    pages = Page.created_in_year('2008').created_in_month('2')
    pages.should include(p)
  end

  it "has_finder should not find pages in other months" do
    p = create_valid_page(:created_at => Date.new(2008, 2))
    p2 = create_valid_page(:created_at => Date.new(2008, 3))
    pages = Page.created_in_year('2008').created_in_month('2').find :all
    pages.should include(p)
    pages.should_not include(p2)
  end

  it "has_finder for allowed accepts multiple arguments" do
    u = create_valid_user
    lambda {Page.allowed(u)}.should_not raise_error
    lambda {Page.allowed(u, :view)}.should_not raise_error
    pending "Page.allowed accepts variable number of arguments"
  end

  describe "page_type finder" do
    before { create_page :type => 'Tool::Image' }
    it "accepts class names as strings" do
      Page.page_type('Tool::Image').should_not be_empty
    end
    it "accepts class names as symbols" do
      Page.page_type(:image).should_not be_empty
    end
    it "finds subclasses" do
      Page.page_type(:asset).should_not be_empty
    end
    it "finds wikis" do
      create_page :type => 'Tool::TextDoc'
      Page.page_type(:wiki).should_not be_empty
    end
    it "finds tasks" do
      create_page :type => 'Tool::TaskList'
      Page.page_type(:task).should_not be_empty
    end
    it "finds ranked vote" do
      create_page :type => 'Tool::RankedVote'
      Page.page_type(:vote).should_not be_empty
    end
    it "finds rate many" do
      create_page :type => 'Tool::RateMany'
      Page.page_type(:poll).should_not be_empty
    end
    it "finds subclasses of subclasses" do
      p = create_page :type => 'Tool::ExternalVideo'
      Page.page_type(:asset).map(&:id).should include(p.id)
    end
  end

  describe "tool creation" do
    before do
      @page.data = (@poll = Poll::Poll.create )
      @page.save
    end
    it "can attach a tool" do
      @poll.pages.first.should == @page
      
    end
  end
  describe "discussion creation" do
    before do
      @page.discussion = (@discussion = Discussion.create!)
      @page.save
    end
    it "can attach a discussion" do
      @discussion.page.should == @page
    end
  end

  describe "participation" do
    before do
      @page = create_valid_page :title => 'zebra'
      @user = create_valid_user
      @group = create_valid_group
      @page.add(@user, :star => true )
      @page.add @group
    end

    it "should be connected to a user" do
      @page.users.should include(@user)
    end
    it "should find the participation using the user id" do
      @page.user_participations.find_by_user_id(@user.id).should be_star
    end

    it "connects a user to the page" do
      @user.pages.should include(@page)
    end

    it "should be connected to the group" do
      @page.groups.should include(@group)
    end

    it "connects a group to the page" do
      @group.pages.should include(@page)
    end

    it "loads associations from db" do
      new_page = Page.find( @page.id )
      new_page.users.should include(@user)
    end

    it "drops user from collection on remove" do
      @page.remove(@user)
      @page.users.should_not include(@user)
    end

    it "drops group from collection on remove" do
      @page.remove(@group)
      @page.groups.should_not include(@group)
    end

    it "includes a copy of the group name" do
      @page.save
      pending "TODO explain why the name of a randomly chosen group from page.groups is important"
      @page.group_name.should == @group.name
    end

  end

  describe "associations" do
    it "loads correctly" do
      %w- groups group_participations users user_participations data discussion assets created_by updated_by -.map(&:to_sym).each do |assoc|
        lambda { @page.send assoc }.should_not raise_error 
      end
    end
  end

  describe "find pages with Page.allowed" do

    before do
      @user = create_valid_user(:login => 'guinea_pig')

      # groups the user belongs to, 1 as an admin and 1 as a member
      @admins_group = create_valid_group(:name => 'admin_group')
      @member_group = create_valid_group(:name => 'member_group')

      # a group granting permission to the user (non-member)
      @granting_group = create_valid_group(:name => 'granting_group')

      # user memberships
      Membership.create(:group => @admins_group, :user => @user, :role => 'administrator')
      Membership.create(:group => @member_group, :user => @user, :role => 'member')

      # the user should be able to view these without any special permissions
      @public_page      = create_valid_page( :title => 'public', :public => true )
      @owned_page       = create_valid_page( :title => 'user', :public => false, :created_by_id => @user.id )

      # group membership pages
      @group_admin_page   = create_valid_page( :title => 'group_admin', :public => false, :group => @admins_group )
      @member_page        = create_valid_page( :title => 'member', :public => false, :group => @member_group )

      # explicit permission pages 
      @view_page        = create_valid_page( :title => 'view_page', :public => false )
      @view_edit_page   = create_valid_page( :title => 'view_edit_page', :public => false )
      @participate_page = create_valid_page( :title => 'participate_page', :public => false )
      @admin_page       = create_valid_page( :title => 'admin_page', :public => false, :group => @granting_group )

      # a private page that doesn't belong to the user and should not be viewable, or
      # anything else for that matter
      @private_page     = create_valid_page( :title => 'private_page', :public => false )

      # grant user permissions
      Permission.grant(:view,         @view_page,         @granting_group, @user)
      Permission.grant(:participate,  @participate_page,  @granting_group, @user)
      Permission.grant(:edit,         @view_edit_page,    @granting_group, @user)
      Permission.grant(:admin,        @admin_page,        @granting_group, @user)
    end

    it "should be set up" do
      Page.count.should be(10) # includes the top global @page
      Permission.count.should be(4)

      @user.memberships.count.should be(2)

      @user.has_permission_to(:view, @view_page).should be_true
      @user.has_permission_to(:view, @view_edit_page).should be_true
      @user.has_permission_to(:edit, @view_edit_page).should be_true
    end

    it "Page.permitted should only find explicitly permitted pages for the user" do
      # 4, 1 view only, 1 view/edit, 1 view/edit/participate, and 1 admin
      Page.permitted_for(@user, :view       ).size.should be(4)
      Page.permitted_for(@user, :participate).size.should be(3)
      Page.permitted_for(@user, :edit       ).size.should be(2)
      Page.permitted_for(@user, :admin      ).size.should be(1)
    end

    describe "when searching for allowed to :view" do
      before do
        @pages = Page.allowed(@user, :view)
      end

      it "should find correct number of allowed pages" do
        # 1 public, 1 'owned', 4 explicity permitted, 2 thru membership
        @pages.size.should be(8)
      end

      it "should include all expected pages" do
        @pages.should include(@public_page)
        @pages.should include(@owned_page)
        @pages.should include(@view_page)
        @pages.should include(@view_edit_page)
        @pages.should include(@participate_page)
        @pages.should include(@admin_page)
        @pages.should include(@group_admin_page)
        @pages.should include(@member_page)
      end

      it "should not include any unexpected pages" do
        @pages.should_not include(@private_page)
      end
    end

    describe "when searching for allowed to :participate" do
      before do
        @pages = Page.allowed(@user, :participate)
      end

      it "should find the correct count of allowed pages" do
        # 1 public, 1 'owned', 3 explicity permitted, 2 thru role
        @pages.size.should be(7)
      end

      it "should include all expected pages" do
        @pages.should include(@public_page)
        @pages.should include(@owned_page)
        @pages.should include(@participate_page)
        @pages.should include(@view_edit_page)
        @pages.should include(@admin_page)
        @pages.should include(@member_page)
        @pages.should include(@group_admin_page)
      end

      it "should not include any unexpected pages" do
        @pages.should_not include(@private_page)
        @pages.should_not include(@view_page)
        @pages.should_not include(@page)
      end
    end

    describe "when searching for allowed to :edit" do
      before do
        @pages = Page.allowed(@user, :edit)
      end

      it "should find the correct count of allowed pages" do
        # 1 public, 1 'owned', 2 explicity permitted, 1 thru role
        @pages.size.should be(5)
      end

      it "should include all expected pages" do
        @pages.should include(@public_page)
        @pages.should include(@owned_page)
        @pages.should include(@view_edit_page)
        @pages.should include(@admin_page)
        @pages.should include(@group_admin_page)
      end

      it "should not include any unexpected pages" do
        @pages.should_not include(@private_page)
        @pages.should_not include(@view_page)
        @pages.should_not include(@participate_page)
        @pages.should_not include(@member_page)
      end
    end

    describe "when searching for allowed to :admin" do
      before do
        @pages = Page.allowed(@user, :admin)
      end

      it "should find the correct count of allowed pages" do
        # 1 'owned', 1 explicity permitted to admin, 1 thru group role
        @pages.size.should be(3)
      end

      it "should include all expected pages" do
        @pages.should include(@owned_page)
        @pages.should include(@admin_page)
        @pages.should include(@group_admin_page)
      end

      it "should not include any unexpected pages" do
        @pages.should_not include(@public_page)
        @pages.should_not include(@private_page)
        @pages.should_not include(@view_page)
        @pages.should_not include(@participate_page)
        @pages.should_not include(@view_edit_page)
        @pages.should_not include(@member_page)
      end
    end
  end

  describe "checking permissions with allows" do
    before do
      @user = create_valid_user(:login => 'subject')
    end

    it "should check it, yo" do
      @page.allows?(@user, :view).should be_false
    end
  end

end
