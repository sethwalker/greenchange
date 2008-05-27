require File.dirname(__FILE__) + '/../spec_helper'

describe PageObserver do
  before do
    @observer = PageObserver.instance
  end
  it "should create network events" do
    @page = create_page
    @page.created_by = (user = create_user)
    lambda { @observer.after_create(@page) }.should change( NetworkEvent, :count )
  end
end
