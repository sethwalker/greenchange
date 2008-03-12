require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe "A group membership" do
  before do
    @group  = create_valid_group
  end

  it "should have a role (not empty)" do
    fozzie = create_valid_user :login => 'fozzie'

    @group.memberships.create :user => fozzie, :group => @group
    @group.membership_for(fozzie).role.should_not be_blank
  end

  it "should have a role that is defined" do
    kermit = create_valid_user :login => 'kermit'

    @group.memberships.create :user => kermit, :group => @group,
                              :role => :administrator
    @group.membership_for(kermit).role.should == :administrator
  end

  it "requires a role to be valid" do
    membership = @group.memberships.create( :user => create_valid_user, :role => '' )
    membership.should have_at_least(1).errors_on(:role)
    
  end

  it "defaults to a member role" do 
    membership = @group.memberships.create( :user => create_valid_user )
    membership.role.should == :member

  end
end
