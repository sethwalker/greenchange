require File.dirname(__FILE__) + '/../spec_helper'

describe IconResource do
  it "expires the icons" do
    controller = GroupsController.new
    controller.stub!(:icon_resource).and_return('group_icon')
    controller.stub!(:icon_path_for).and_return('string?1231233')
    controller.should_receive(:expire_page).with('string').any_number_of_times
    controller.send(:refresh_icon)
  end
end
