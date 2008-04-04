require File.dirname(__FILE__) + '/../spec_helper'

describe Committee do

  before do
    @group = Group.create :name => 'riseup'
    @committee_1 = Committee.create :name => 'finance'
    @committee_2 = Committee.create :name => 'food'
    @group.committees << @committee_1
    @group.committees << @committee_2
  end
  
  describe "when within a group" do
    it "has 2 committees" do
      @group.committees.count.should == 2
    end

    it "parent is a group" do
      @committee_1.parent.should == @group 
    end

    it "group is updated when committee goes away" do
      @committee_1.destroy
      @group.committees.count.should be(1)
    end

    it "committees dies with group" do
      @group.destroy
      Committee.find_by_name('food').should be_nil
    end
  end

  describe "with members" do
    before do
      @user = create_valid_user :login => 'kangaroo'
    end
    
   
    it "does not grant membership by default" do
      assert(!@user.member_of?(@group), 'user should not be member yet')
      new_membership = @user.memberships.create :group => @group
      #pp @group.committees
      #@user.update_membership_cache new_membership #have to call explicitly???

      @user.groups(true)
      assert @user.member_of?(@group), 'user should be member of group'
      assert(@user.direct_member_of?(@group), 'user should be a direct member of the group')
      @user.groups.delete(@group)

      assert(!@user.member_of?(@group), 'user should not be member of group after being removed')
      assert(!@user.member_of?(@committee_1), 'user should not be a member of committee')
                 
    end

    it "adds memberships for committees as well" do
      pending 're-enable committe support'
      assert @user.member_of?(@committee_1), 'user should also be a member of committee'
      assert(!@user.direct_member_of?(@committee_1), 'user should not be a direct member of the committee')
    end 
  end
  
  describe "when naming" do
    before do
      @group.committees.delete_all
      @committee = Committee.new :name => 'outreach'
      @group.committees << @committee
      @committee.save
      @group.reload
    end
    
    it "should include the parent group name" do
      @committee.full_name.should == 'riseup+outreach'
    end

    it "should change the full name when the short name changes" do
      @committee.name = 'legal'
      @committee.save
      @committee.full_name.should == 'riseup+legal'
    end
  
    it "should change the committee name when the group name changes" do
      @group.name = 'riseup-collective'
      @group.save
      @group.committees.first.full_name.should == 'riseup-collective+outreach'
    end
  end
  
  it "should require a name to be valid" do
    group = Committee.create
    group.should_not be_valid
  end
  
  it "should assign unnamed committees to parents" do
    lambda {
      parent = Group.create :name => 'parent'
      @committee = Committee.new
      @committee.parent = parent
    }.should_not raise_error
  end
  
  it "has working associations" do
    lambda {
      %w- parent avatar admin_group collections issues memberships pages users -.map( &:to_sym).each do |assoc|
        begin
          @committee_1.send assoc
        rescue
          raise "#{assoc} failed to load for committee"
        end
      end
    }.should_not raise_error
  end
  
  describe "permission for members of committee" do
    before do
      @user = create_valid_user
      @committee_1.memberships.create :user => @user
      @group_page = Page.create :title => 'a group page', :public => false

      ## this api is not clear.  add?  add what? a picture .. or permissions?
      # seems to call for separate methods
      @group_page.add(@group, :access => :admin)
      @committee_page = Page.create :title => 'a committee page', :public => false, :group => @committee_1
      @committee_page.add(@committee_1, :access => :admin)
    end

    it "can access committee  pages" do
      @user.may?(:view, @committee_page).should be_true
    end

    it "cannot access group pages" do
      @user.may?(:view, @group_page).should be_false
    end
  end
end

