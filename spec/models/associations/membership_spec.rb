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

describe Membership, "with DIA hooks" do
  it "should remove from no groups group when a membership is created" do
    user = create_user
    group = create_group
    DemocracyInAction::Proxy.should_receive(:find_by_local_type_and_local_id_and_name).with('User', user.id, 'no_groups_group_membership')
    Membership.create(:user => user, :group => group)
  end

  it "should add to group if no more memberships after destroy" do
    u = create_user
    g = create_group
    m = Membership.create :user => u, :group => g
    m.stub!(:supporter_key).and_return(5)
    DemocracyInAction::API.stub!(:disabled?).and_return(false)
    DemocracyInAction::API.stub!(:new).and_return(api = stub('api', :process => 123))
    m.democracy_in_action_proxies.each {|p| p.stub!(:destroy) }
    m.destroy
    DemocracyInAction::Proxy.find_by_name_and_local_id('no_groups_group_membership', u.id).should_not be_nil
  end
end
