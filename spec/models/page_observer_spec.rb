require File.dirname(__FILE__) + '/../spec_helper'

describe PageObserver do
  before do
    @observer = PageObserver.instance
  end
  it "should create network events" do
    @page = create_page
    lambda { @observer.after_create(@page) }.should change( NetworkEvent, :count )
  end
  it "should never make new notifications for recently updated pages" do
    @page = create_page(:updated_by => create_user)
    lambda{ @page.save }.should_not change( Notification, :count )
  end
  it "should have no recipients if a network event created in the last hour" do
    @page = create_page(:updated_by => create_user)
    NetworkEvent.should_receive(:create!).with(hash_including(:recipients => []))
    @page.save!
  end
  it "should have recipients if a network event created more than an hour ago" do
    @page = create_page(:updated_by => create_user)
    @page.network_events.each { |nev| nev.update_attribute :created_at, 3.hours.ago }
    NetworkEvent.should_receive(:create!).with(hash_including(:recipients => PageObserver.instance.watchers(@page)))
    @page.save!
  end
  it "should create network events as a callback" do
    @page = new_page
    PageObserver.instance.should_receive(:after_create).with(@page)
    @page.save!
  end
  describe "watchers" do
    before do
      @user = create_user
      @page = new_page :created_by => @user
    end
    it "should include the creator" do
      @observer.watchers(@page).should include(@user)
    end
    it "should include the creators contacts" do
      @user.contacts << (@contact = create_user)
      @observer.watchers(@page).should include(@contact)
    end
    it "should include the groups members" do
      @page.group = (@group = create_group)
      @group.members << (@member = create_user)
      @observer.watchers(@page).should include(@member)
    end
  end
end
