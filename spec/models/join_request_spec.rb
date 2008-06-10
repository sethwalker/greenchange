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

    it "recognizes events" do
      @req.requestable = Event.create :is_all_day => true, :page => Tool::Event.create( :title => 'joppa' )
      @req.should be_event
    end
  end

  describe "approvable" do
    before do
      @group = create_valid_group
      @req.requestable = @group
      @req.sender_id = (@sender = create_user).id
      @req.recipient = create_user
      @req.approved_by = create_user
      @req.save
    end

    it "does not allow approval by random users" do
      @req.approve!
      @req.should be_pending
    end

    it "does allow approval by admins" do
      @group.should_receive(:allows?).and_return(true)
      @req.approve!
      @req.should be_approved
    end

    describe "successful approvals" do
      before do
        @group.stub!(:allows?).and_return(true)
      end

      it "can create new memberships" do
        lambda{ @req.approve! }.should change( Membership, :count ).by(1)
      end

      it "can create new rsvps" do
        event = Event.create! :is_all_day => true, :page => Tool::Event.create!( :title => 'joppa' )
        event.stub!(:allows?).and_return(true)
        @req.requestable = event
        lambda{ @req.approve! }.should change( Rsvp, :count ).by(1)
      end

    end

  end
end
