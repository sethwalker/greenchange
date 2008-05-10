require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/messages_spec_helper'

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
      event_page = Tool::Event.create :title => 'pass'
      @event = event_page.build_data :is_all_day => true, :page => event_page
      Tool::Event.stub!(:find ).and_return event_page
      get :new, :event_id => event_page.to_param
      assigns[:invitation].invitable.should == @event
    end

  end

  describe "create" do
    describe "group invitations" do
      def act!
        post :create, :group_id => @group.name, :invitation => { :recipient_id => @recipient.id }
      end
      it "makes group invitations" do
        act!
        assigns[:invitations].first.group.should == @group
      end
      it "assigns the current sender" do
        act!
        assigns[:invitations].first.sender.should == @current_user
      end
      it "checks that the sender is authorized to admin" do
        current_user = login_valid_user
        @controller.should_receive( :access_denied )
        
        post :create, :group_id => @group.name, :invitation => { :recipient_id => @recipient.id }
      end
    end

    describe "contact invitations" do
      def act!
        post :create, :invitation => { :recipient_id => @recipient.id, :body => 'i like u' }
      end
      it "should assign an invitation" do
        act!
        assigns[:valid_invitations].should_not be_empty
        assigns[:invalid_invitations].should be_empty
      end
      it "should create a pending invitation" do
        lambda{ act! }.should change( @recipient.invitations_received.pending, :count ).by(1)
      end
    end

    it_should_behave_like "message creation"
    def current_model; Invitation; end
    def object_name; :invitation; end
    def objects_collection; :invitations; end
    def invalid_objects_collection; :invalid_invitations; end
  end

  describe "when destroying" do
    def current_model; Invitation; end
    it_should_behave_like "message destruction"
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

  describe "contacts" do
    before do
      @invited_user = create_user
    end
    describe "new" do
      it "should be a contact invitation" do
        get :new
        assigns[:invitation].should be_contact
      end
      it "should be an invitation to be contacts with the current user" do
        get :new
        assigns[:invitation].invitable.should  == @current_user
      end
    end

  end
end
