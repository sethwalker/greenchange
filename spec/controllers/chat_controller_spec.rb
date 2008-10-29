require File.dirname(__FILE__) + '/../spec_helper'

describe ChatController do
  integrate_views
  describe "when polling for updates" do
    before(:all) do
      @writer = create_user
      @reader = create_user
      @channel = ChatChannel.find_or_create_by_name('main')
    end

    before do
      login_user @reader
      @message = ChatMessage.create(:channel => @channel, :content => 'bzzzr', :sender => @writer)
    end

    def act!
      xhr :post, :poll_channel_for_updates, :id => @channel.id
    end

    it "is successful" do
      act!
      response.should be_success
    end
    it "shows new messages" do
      act!
      response.should have_text(/bzzzr/)
    end
    it "shows messages only once" do
      act!
      act!
      response.should_not have_text(/bzzzr/)
    end
  end






  it "flunk" do
    flunk
  end

end
