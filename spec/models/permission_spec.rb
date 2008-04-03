require File.dirname(__FILE__) + '/../spec_helper'

describe "Permission" do

  before do
    @user           = create_valid_user(:login => 'guinea_pig')
    @group          = create_valid_group(:name => 'granting_group')
    @page           = create_valid_page( :title => 'page', :public => false )
    @private_page   = create_valid_page( :title => 'private_page', :public => false )
  end

  describe "in general" do
    before do
      Permission.grant(:view, @page, @group, @user)
    end

    it "should create a permission record when granting" do
      Permission.exists(@page, @group, @user).should be_true
    end

    it "should not create a new permission record when granting new actions" do
      Permission.grant(:edit, @page, @group, @user)
      Permission.count.should be(1)
    end

    it "should update granted permissions" do
      Permission.grant(:edit, @page, @group, @user)

      @user.has_permission_to(:view,        @page).should be_true
      @user.has_permission_to(:participate, @page).should be_true
      @user.has_permission_to(:edit,        @page).should be_true
      @user.has_permission_to(:admin,       @page).should be_false
    end

    it "should update revoked permissions" do
      Permission.grant(:edit, @page, @group, @user)
      Permission.revoke(:edit, @page, @group, @user)

      @user.has_permission_to(:view,        @page).should be_true
      @user.has_permission_to(:participate, @page).should be_true
      @user.has_permission_to(:edit,        @page).should be_false
      @user.has_permission_to(:admin,       @page).should be_false
    end
  end

  describe "when granting permissions" do
    it "should only grant view when granting :view" do
      Permission.grant(:view, @page, @group, @user)

      @user.has_permission_to(:view,        @page).should be_true
      @user.has_permission_to(:participate, @page).should be_false
      @user.has_permission_to(:edit,        @page).should be_false
      @user.has_permission_to(:admin,       @page).should be_false
    end

    it "should grant view/participate when granting :participate" do
      Permission.grant(:participate, @page, @group, @user)

      @user.has_permission_to(:view,        @page).should be_true
      @user.has_permission_to(:participate, @page).should be_true
      @user.has_permission_to(:edit,        @page).should be_false
      @user.has_permission_to(:admin,       @page).should be_false
    end

    it "should grant view/participate/edit when granting :edit" do
      Permission.grant(:edit, @page, @group, @user)

      @user.has_permission_to(:view,        @page).should be_true
      @user.has_permission_to(:participate, @page).should be_true
      @user.has_permission_to(:edit,        @page).should be_true
      @user.has_permission_to(:admin,       @page).should be_false
    end

    it "should grant all when granting :admin" do
      Permission.grant(:admin, @page, @group, @user)

      @user.has_permission_to(:view,        @page).should be_true
      @user.has_permission_to(:participate, @page).should be_true
      @user.has_permission_to(:edit,        @page).should be_true
      @user.has_permission_to(:admin,       @page).should be_true
    end
  end

  describe "when revoking permissions" do
    before do
      Permission.grant(:admin, @page, @group, @user)
    end

    it "should keep view/participate/edit when revoking :admin" do
      Permission.revoke(:admin, @page, @group, @user)

      @user.has_permission_to(:view,        @page).should be_true
      @user.has_permission_to(:participate, @page).should be_true
      @user.has_permission_to(:edit,        @page).should be_true
      @user.has_permission_to(:admin,       @page).should be_false
    end

    it "should keep view/participate when revoking :edit" do
      Permission.revoke(:edit, @page, @group, @user)

      @user.has_permission_to(:view,        @page).should be_true
      @user.has_permission_to(:participate, @page).should be_true
      @user.has_permission_to(:edit,        @page).should be_false
      @user.has_permission_to(:admin,       @page).should be_false
    end

    it "should keep view when revoking :participate" do
      Permission.revoke(:participate, @page, @group, @user)

      @user.has_permission_to(:view,        @page).should be_true
      @user.has_permission_to(:participate, @page).should be_false
      @user.has_permission_to(:edit,        @page).should be_false
      @user.has_permission_to(:admin,       @page).should be_false
    end

    it "should delete permission record when no actions are permitted" do
      Permission.revoke(:view, @page, @group, @user)
      Permission.exists(@page, @group, @user).should be_false

      @user.has_permission_to(:view,        @page).should be_false
      @user.has_permission_to(:participate, @page).should be_false
      @user.has_permission_to(:edit,        @page).should be_false
      @user.has_permission_to(:admin,       @page).should be_false
    end
  end
end
