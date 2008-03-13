require File.dirname(__FILE__) + '/../spec_helper'

describe ToolCreation do
  include ToolCreation
  before do
    @page = create_page(:title => 'add participants page')
    @creator = User.new :login => 'creator'
    @member = User.new :login => 'member'
    @group = Group.new :name => 'agroup'
    @group.stub!(:users).and_return([@creator, @member])
    Group.should_receive(:get_by_name).with('groupname').and_return(@group)
  end

  def current_user
    @creator
  end

  it "add_participants should call add" do
    @page.should_receive(:add).at_least(3).times
    add_participants! @page, {:group_name => 'groupname', :announce => true} #or group_id
  end
end
