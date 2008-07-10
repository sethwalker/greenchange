require File.dirname(__FILE__) + '/../../spec_helper'

describe "create page partial" do
  before do
    @page = create_page :title => 'a page', :created_by => (@creator = create_user), :group => (@group = create_group), :created_at => 1.day.ago
    @page.updated_by = (@updater = create_user)
    @page.save
    @event = NetworkEvent.find(PageObserver.instance.after_update(@page).id)
  end

  def act!
    render :partial => "network_events/update_page", :locals => {:event => @event}
  end

  describe "should render without error" do
    it do
      lambda { act! }.should_not raise_error
      response.body.should =~ /Updated by/
    end

    it "when the page is destroyed" do
      @page.destroy
      lambda { act! }.should_not raise_error
    end

    it "when the group is destroyed" do
      @group.destroy
      lambda { act! }.should_not raise_error
    end

    it "when the creator is destroyed" do
      #pending "SPHINX"
      @user.stub!(:delta).and_return(false)
      @creator.destroy
      lambda { act! }.should_not raise_error
    end

    it "when the updater is destroyed" do
      #pending "SPHINX"
      @user.stub!(:delta).and_return(false)
      @updater.destroy
      lambda { act! }.should_not raise_error
    end
  end
end
