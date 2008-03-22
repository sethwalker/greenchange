require File.dirname(__FILE__) + '/../spec_helper'

describe Page, "finding with permissions enabled" do

  before do
    @user = create_valid_user(:login => 'guinea_pig')
    
    # groups, one the user admins and the other explicitly grants them the permission
    # to view and edit specific pages
    @admins_group = create_valid_group(:name => 'admin_group')
    @granting_group = create_valid_group(:name => 'granting_group')
    @member_group = create_valid_group(:name => 'member_group')

    # setup the user memberships
    @admin_membership = Membership.new(:group => @admins_group, :user => @user, :role => 'administrator')
    @admin_membership.save!

    @normal_membership = Membership.new(:group => @member_group, :user => @user, :role => 'member')
    @normal_membership.save!

    # the user should be able to view these without any special permissions
    @public_page      = create_valid_page( :title => 'public', :public => true )
    @user_page        = create_valid_page( :title => 'user', :public => false, :created_by_id => @user.id )

    @admin_page       = create_valid_page( :title => 'admin', :public => false, :group => @admin_group )
    @member_page      = create_valid_page( :title => 'member', :public => false, :group => @member_group )

    # user can only act on this page when an explicit permission has been given
    @permitted_view   = create_valid_page( :title => 'permitted_view', :public => false ) # will be later
    @permitted_edit   = create_valid_page( :title => 'permitted_edit', :public => false ) # will be later

    # two private pages that don't belong to the user and should not be viewable, or
    # anything else for that matter, by them
    @private_page_1   = create_valid_page( :title => 'private1', :public => false )
    @private_page_2   = create_valid_page( :title => 'private2', :public => false )

    # grant view permission on the page
    @view_permission = Permission.new(
      :resource     => @permitted_view,
      :grantor      => @granting_group,
      :grantee      => @user,
      :view         => true,
      :edit         => false,
      :participate  => false,
      :admin        => false
    )

    @view_permission.should be_valid
    lambda { @view_permission.save! }.should_not raise_error

    # grant edit (and view) permission on the page
    @edit_permission = Permission.new(
      :resource     => @permitted_edit,
      :grantor      => @granting_group,
      :grantee      => @user,
      :view         => true,
      :edit         => true,
      :participate  => false,
      :admin        => false
    )

    @edit_permission.should be_valid
    lambda { @edit_permission.save! }.should_not raise_error

    @participate_permission = Permission.new(
      :resource     => @private_page_1, # on a private page, for kicks
      :grantor      => @user,
      :grantee      => @user,
      :view         => true,
      :edit         => true,
      :participate  => true,
      :admin        => false
    )
    @participate_permission.save!

    @admin_permission = Permission.new(
      :resource     => @admin_page,
      :grantor      => @granting_group,
      :grantee      => @user,
      :view         => false,
      :edit         => false,
      :participate  => false,
      :admin        => true
    )
    @admin_permission.save!

  end

  it "should be set up" do
    # check our test setup
    Page.count.should be(8)
    Permission.count.should be(4)

    # more setup tests, 1 as admin, and 1 as member
    @user.memberships.count.should be(2)

    @user.has_permission_to(:view, @permitted_view).should be_true
    @user.has_permission_to(:edit, @permitted_edit).should be_true
  end

  it "Page.permitted should only find explicitly permitted pages for the user" do
    # 3, 1 view only, 1 view/edit, and one view/edit/participate
    Page.permitted_for(@user, :view).size.should be(3)
  end

  it "should find correct number of pages allowed for viewing by the user" do
    # 1 public, 1 'owned', and 3 explicity permitted to view, 1 thru membership
    pending do
    Page.allowed(@user, :view).size.should be(5)
    end
  end

  describe "when searching for allowed to :view" do
    before do
      @pages = Page.allowed(@user, :view)
    end
    it "should include the public page" do
      @pages.should include(@public_page)
    end
    it "should include the owned page" do
      @pages.should include(@user_page)
    end
    it "should include the page allowed by membership" do
      @pages.should include(@member_page)
    end
  end

  it "should find correct number of pages allowed for editing by the user" do
    # 1 public, 1 'owned', and 2 explicity permitted to edit
    Page.allowed(@user, :edit).size.should be(4)
  end

  it "should find correct number of pages allowed for participation by the user" do
    # 1 public, 1 'owned', and 1 explicity permitted to participate
    pending do
    Page.allowed(@user, :participate).size.should be(3)
    end
  end

  it "should find correct number of pages allowed for administration by the user" do
    # 1 explicity permitted to admin, 1 thru group role
    Page.allowed(@user, :admin).size.should be(2)
  end
end
