require File.dirname(__FILE__) + '/../spec_helper.rb'

describe InvitationsController do
  before do
    @current_user = login_valid_user
    @group = create_valid_group
    @recipient = create_valid_user
    Membership.create :user => @current_user, :group => @group, :role => :administrator
  end
  describe "new is context aware" do
    before do
      Group.stub!(:find_by_name).and_return @group
    end

    it "should create new invitations to groups" do
      get :new, :group_id => @group.name
      assigns[:invitation].invitable.should == @group
    end
    it "should pass thru params from the url" do
      get :new, :group_id => @group.name, :invitation => { :recipient_id => @recipient.id }
      assigns[:invitation].recipient_id.should == @recipient.id
    end

    it "should create new invitations to events" do
      @event = Tool::Event.create :title => 'pass'
      Tool::Event.stub!(:find ).and_return @event
      get :new, :event_id => @event.to_param
      assigns[:invitation].invitable.should == @event
    end

  end

  describe "create" do
    describe "can do group invitations" do
      def act!
        post :create, :group_id => @group.name, :invitation => { :recipient_id => @recipient.id }
      end
      it "makes group invitations" do
        act!
        assigns[:invitation].invitable.should == @group
      end
      it "assigns the current sender" do
        act!
        assigns[:invitation].sender.should == @current_user
      end
      it "checks that the sender is authorized to admin" do
        current_user = login_valid_user
        @controller.should_receive( :access_denied )
        
        post :create, :group_id => @group.name, :invitation => { :recipient_id => @recipient.id }
      end
    end
  end

  describe "when responding" do
    before do
      @invitation = Invitation.create :sender => @current_user, :recipient => @recipient, :invitable => @group, :state => "pending"
      Invitation.stub!(:find).and_return(@invitation)
    end

    describe "accept" do
      def act!
        put :accept, :id => @invitation
      end
      it "accepts the invitation" do
        @invitation.should_receive(:accept!)
        act!
      end
      it "creates a group membership" do
        act!
        @group.members(true).should include(@recipient)
      end
    end

    describe "ignore" do
      def act!
        put :ignore, :id => @invitation
      end

      it "ignores the invitation" do
        @invitation.should_receive(:ignore!)
        act!
      end

    end
  end
end
