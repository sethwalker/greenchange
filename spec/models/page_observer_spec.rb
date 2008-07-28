require File.dirname(__FILE__) + '/../spec_helper'

describe PageObserver do
  before do
    @observer = PageObserver.instance
  end
  it "should create network events" do
    @page = create_page :created_by => (user = create_user)
    lambda { @observer.after_create(@page) }.should change( NetworkEvent, :count )
  end
  it "should create network events as a callback" do
    @page = new_page :created_by => (user = create_user)
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
  it "should observe pages!  wtf!" do

  end
end
