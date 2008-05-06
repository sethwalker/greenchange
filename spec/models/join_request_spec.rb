require File.dirname(__FILE__) + '/../spec_helper'

describe JoinRequest do
  before do
    @req = JoinRequest.create :state => "pending"
  end

  describe "requestable" do
    it "recognizes its type" do
      @req.requestable = create_valid_group
      @req.should be_group
    end
  end

  describe "approvable" do
    before do
      @group = create_valid_group
      @req.requestable = @group
      @req.sender_id = create_valid_user.id
      @req.recipient = create_valid_user
      @req.save
    end

    it "does not allow approval by random users" do
      @req.approved_by = create_valid_user
      @req.approve!
      @req.should be_pending
    end
    it "saves" do
      @req.should be_valid
    end

    it "does allow approval by admins" do
      @group.should_receive(:allows?).and_return(true)
      @req.group = @group
      @req.sender = create_valid_user
      @req.approved_by = create_valid_user
      @req.approve!
      #@req.should be_approved
      @req.current_state.should == :approved
    end

  end
end
