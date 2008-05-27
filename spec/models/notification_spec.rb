require File.dirname(__FILE__) + '/../spec_helper'

describe Notification do
  before do
    @notification = Notification.new
  end
  it "requires a user" do
    @notification.save
    @notification.should have_at_least(1).errors_on(:user_id)
  end
  it "requires a network event" do
    @notification.save
    @notification.should have_at_least(1).errors_on(:network_event_id)
  end
end

