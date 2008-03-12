require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "A group membership" do
  before do
    @group  = create_valid_group
  end

  it "should have a role (not empty)" do
    fozzie = create_valid_user :login => 'fozzie'

    @group.memberships.create :user => fozzie, :group => @group
    @group.membership_for(fozzie).role.should_not be_empty
  end

  it "should have a role that is defined" do
    kermit = create_valid_user :login => 'kermit'

    @group.memberships.create :user => kermit, :group => @group,
                              :role => :administrator
    @group.membership_for(kermit).role.should == 'administrator'
  end
end
