require File.dirname(__FILE__) + '/../../spec_helper'

describe "create membership partial" do
  before do
    @membership = create_membership :user => (@user = create_user), :group => (@group = create_group)
    @event = @membership.created_network_event
  end

  def act!
    render :partial => "network_events/create_membership", :locals => {:event => @event}
  end

  describe "should render without error" do
    it do
      lambda { act! }.should_not raise_error
    end

    it "shen the membership is destroyed" do
      @membership.destroy
      lambda { act! }.should_not raise_error
    end

    it "when the group is destroyed" do
      @group.destroy
      lambda { act! }.should_not raise_error
    end

    it "when the user is destroyed" do
      @user.destroy
      lambda { act! }.should_not raise_error
    end
  end
end
