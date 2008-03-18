require File.dirname(__FILE__) + '/../spec_helper'

describe MembershipRequest do
  before do
    @r = MembershipRequest.create
  end
  it "allows approval if approver has rights" do
    @r.should_receive(:after_approved)
    @r.approved_by = User.new
    @r.group = mock_model(Group)
    @r.group.stub!(:allows?).and_return(true)
    @r.approve!
  end
  it "should deny approval if approver doesn't have rights" do
    @r.should_receive(:after_approved).never
    @r.approved_by = User.new
    @r.group = mock_model(Group)
    @r.group.stub!(:allows?).and_return(false)
    @r.approve!
  end
  describe "after approval" do
    before do
      @r.stub!(:approval_allowed).and_return(true)
      @r.user = create_user
      @r.group = create_group
      @r.approve!
    end
    it "is approved" do
      @r.should be_approved
    end
    it "creates a membership" do
      Membership.find_by_user_id_and_group_id(@r.user.id, @r.group.id).should_not be_nil
    end
    it "should be resolved" do
      @r.should be_resolved
    end
  end
end
