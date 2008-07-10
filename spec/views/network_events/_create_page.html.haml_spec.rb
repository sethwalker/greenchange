require File.dirname(__FILE__) + '/../../spec_helper'

describe "create page partial" do
  before do
    @page = create_page :title => 'a page', :created_by => (@user = create_user), :group => (@group = create_group)
    @event = NetworkEvent.find(PageObserver.instance.after_update(@page).id)
  end

  def act!
    render :partial => "network_events/create_page", :locals => {:event => @event}
  end

  describe "should render without error" do
    it do
      lambda { act! }.should_not raise_error
    end

    it "when the page is destroyed" do
      @page.destroy
      lambda { act! }.should_not raise_error
    end

    it "when the group is destroyed" do
      @group.destroy
      lambda { act! }.should_not raise_error
    end

    it "when the user is destroyed" do
      #pending "SPHINX"
      @user.stub!(:delta).and_return(false)
      @user.destroy
      lambda { act! }.should_not raise_error
    end
  end
end
