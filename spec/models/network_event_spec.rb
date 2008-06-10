require File.dirname(__FILE__) + '/../spec_helper'

describe NetworkEvent do

  before do
    @event = new_network_event
  end

  describe "when invalid" do
    before do
      @event = NetworkEvent.new
    end

    it "requires a modified item" do
      @event.save
      @event.should have_at_least(1).errors_on(:modified_id)
    end

    it "requires a user" do
      @event.save
      @event.should have_at_least(1).errors_on(:user_id)
    end
    it "requires an action" do
      @event.save
      @event.should have_at_least(1).errors_on(:action)
    end
  end

  # i know it looks like we're testing the serialize method here, 
  # but am not able to serialize pages and i want to know why
  describe "serializing the data_snapshot" do
    it "should work with a new object" do
      @event = create_network_event(:data_snapshot => {:page => new_page})
    end
    it "should work with a saved object" do
      @event = create_network_event(:data_snapshot => {:issue => create_issue})
    end
    it "should work with a saved page" do
      @event = new_network_event(:data_snapshot => {:page => create_page})
    end
  end

  describe "successful save" do
    before do
      @event.user = @actor = create_user
      @event.modified = (@page = create_page(:created_by => @actor))
      @event.recipients = @page.watchers
    end
    it "should create notifications" do
      lambda { @event.save }.should change(Notification, :count)
    end

    describe "for pages in a group" do
      before do
        @group = @event.modified.group = create_group
        @group.members << (@user = create_user)
        @group.members << ( @luser = create_user)
        @event.recipients = @page.watchers
      end
      it "should create a notification for the user" do
        @event.save
        Notification.find_by_user_id(@user.id).should_not be_nil 
      end

      describe "for multiple users" do
        it "should publish notifications for all users" do
          lambda { @event.save }.should change(Notification, :count).by_at_least(2)
        end
      end
    end

    describe "for my contacts" do
      before do
        @user = create_user
        @luser = create_user
        Page.stub!(:allows?).with(@user).and_return(true)
        Page.stub!(:allows?).with(@luser).and_return(false)
        @actor.contacts << @user << @luser
        @event.recipients = @page.watchers
      end
      it "should create a notification for my (allowed) contacts" do
        @event.save
        Notification.find_by_user_id(@user.id).should_not be_nil 
      end
    end

    describe "for a new group membership" do
      before do
        @user = create_user
        @user.contacts << (@contact = create_user)
        @group = create_group
        @group.admins << (@admin = create_user)
      end
      it "should notify the users contacts" do
        m = create_membership(:user => @user, :group => @group)
        @contact.notifications.map {|n| n.network_event.modified}.should include(m)
      end
      it "should notify the group admins" do
        m = create_membership(:user => @user, :group => @group)
        @admin.notifications.map {|n| n.network_event.modified}.should include(m)
      end
    end
  end
end
