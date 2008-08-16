require File.dirname(__FILE__) + '/../spec_helper'

describe "Participations" do

  before do
    TzTime.zone = TimeZone["Pacific Time (US & Canada)"]

    @user = create_user({:login => 'writer'})
    @page = Page.create :title => 'Test Page'
    @page.updated_at = Time.now
    @page.save
  end

  it "should not exist for non-participating users" do
    part = @page.participation_for_user @user
    part.should be_nil
  end

  it "should update viewed-at timestamp for pages viewed by users" do
    # funny thing, viewed doesn't create a participation, but will
    # update its viewed_at if it exists.
    @user.create_participation(@page, {:viewed => true} )
    @user.viewed(@page)

    part = @page.participation_for_user @user
    part.viewed.should be_true
    part.viewed_at.should_not be_nil
  end
end
