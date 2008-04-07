require File.dirname(__FILE__) + '/../../spec_helper'

describe "DemocracyInAction::Mirroring::ActiveRecord" do
  before do
    Object.remove_class User if Object.const_defined?(:User)
    class User < ActiveRecord::Base; end
  end

  it "should after_save" do
    DemocracyInAction.configure do
      mirror(:supporter, User) do
        map('First_Name') {|user| user.name}
      end
    end
    u = User.new :name => 'barack'
    u.democracy_in_action_proxies.build :remote_table => 'supporter', :remote_key => 1234
    DemocracyInAction::Mirroring.stub!(:api).and_return(api = stub('api'))
    api.should_receive(:process).with('supporter', {'key' => 1234, 'First_Name' => 'barack'})
    u.save
  end
end
