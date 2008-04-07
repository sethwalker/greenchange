require File.dirname(__FILE__) + '/../spec_helper'

describe "DemocracyInAction::Mirroring" do

  before do
    Object.remove_class User if Object.const_defined?(:User)
    class User < ActiveRecord::Base; end
  end

  it "should be available thru mirror in configure" do
    DemocracyInAction::Mirroring.should_receive(:mirror).with(:supporter, User)
    DemocracyInAction.configure { mirror(:supporter, User) }
  end

  describe "mirror method" do
    it "should accept a block" do
      lambda { DemocracyInAction::Mirroring.mirror(:supporter, User) { 'code' } }.should_not raise_error
    end
    it "should make map available inside the block" do
      lambda { DemocracyInAction::Mirroring.mirror(:supporter, User) {
        map('First_Name') {|user| user.name }
      } }.should_not raise_error
    end
  end

  describe "a mirrored class" do
    before do
      DemocracyInAction::Mirroring.mirror(:supporter, User)
    end

    it "should include DemocracyInAction::Mirroring::ActiveRecord" do
      User.included_modules.should include(DemocracyInAction::Mirroring::ActiveRecord)
    end

    it "should receive the after save call" do
      DemocracyInAction::Mirroring.mirror(:supporter, User)
      user = User.new
      DemocracyInAction::Mirroring::ActiveRecord.should_receive(:after_save).with(user)
      user.save
    end

    it "should remember the map" do
      User.democracy_in_action.mirrors = [] if User.respond_to?(:democracy_in_action)
      mirror = DemocracyInAction::Mirroring.mirror(:supporter, User) do
        map('First_Name') {|user| user.name }
      end
      u = User.new :name => 'dweezil'
      User.democracy_in_action.mirrors.first.mappings(u)['First_Name'].should == 'dweezil'
      # or:
      mirror.mappings(u)['First_Name'].should == 'dweezil'
    end

    it "should also be able to set static values" do
      User.democracy_in_action.mirrors = [] if User.respond_to?(:democracy_in_action)
      DemocracyInAction::Mirroring.mirror(:supporter, User) do
        map('First_Name', 'moon unit')
      end
      u = User.new :name => 'dweezil'
      User.democracy_in_action.mirrors.first.mappings(u)['First_Name'].should == 'moon unit'
    end

    if ENV['DIA_USER'] && ENV['DIA_PASS'] && ENV['DIA_ORG']
      describe "WITH A CONNECTION TO DIA!!!  to org key:#{ENV['DIA_ORG']}" do
        before do
          DemocracyInAction.configure {
            auth.username = ENV['DIA_USER']
            auth.password = ENV['DIA_PASS']
            auth.org_key  = ENV['DIA_ORG']
          }
        end
        before(:all) do
          DemocracyInAction::API.stub!(:disabled?).and_return(false)
        end

        after do
          DemocracyInAction.configure {
            auth.username = auth.password = auth.org_key = nil
          }
        end
        after(:all) do
          DemocracyInAction::API.stub!(:disabled?).and_return(true)
        end

        describe "when saving" do
          it "should save values" do
            Object.remove_class User if Object.const_defined?(:User)
            class User < ActiveRecord::Base; end
            DemocracyInAction.configure do
              mirror(:supporter, User) do
                map('First_Name', 'alfred')
                map('Last_Name') {|user| user.name}
              end
            end
            @user = User.new :name => 'hitchcock'
            @user.save
            attrs = DemocracyInAction::Mirroring.api.get('supporter', @user.democracy_in_action_proxies.find_by_remote_table('supporter').remote_key).first
            attrs['First_Name'].should == 'alfred'
            attrs['Last_Name'].should == 'hitchcock'
          end
        end
        describe "when updating" do
          it "should update values" do
            Object.remove_class User if Object.const_defined?(:User)
            class User < ActiveRecord::Base; end
            DemocracyInAction.configure do
              mirror(:supporter, User) do
                map('First_Name', 'albert')
                map('Last_Name') {|user| user.name}
              end
            end
            @user = User.new :name => 'einstein'
            @user.save
            attrs = DemocracyInAction::Mirroring.api.get('supporter', @user.democracy_in_action_proxies.find_by_remote_table('supporter').remote_key).first
            attrs['Last_Name'].should == 'einstein'
            @user.update_attributes(:name => 'camus')
            attrs = DemocracyInAction::Mirroring.api.get('supporter', @user.democracy_in_action_proxies.find_by_remote_table('supporter').remote_key).first
            attrs['Last_Name'].should == 'camus'

          end
        end
        describe "when destroying" do
          it "should destroy the record" do
            Object.remove_class User if Object.const_defined?(:User)
            class User < ActiveRecord::Base; end
            DemocracyInAction.configure do
              mirror(:supporter, User) do
                map('First_Name', 'albert')
                map('Last_Name') {|user| user.name}
              end
            end
            @user = User.new :name => 'einstein'
            @user.save
            proxy = @user.democracy_in_action_proxies.find_by_remote_table('supporter')
            DemocracyInAction::Mirroring.api.get('supporter', proxy.remote_key).should_not be_empty
            @user.destroy

            DemocracyInAction::Mirroring.api.get('supporter', proxy.remote_key).should be_empty
          end
        end
      end
    end
  end

  describe "defaults" do
    before do
      @mirror = DemocracyInAction::Mirroring::Mirror.new('supporter', User)
    end
    before do
      @defaults = @mirror.defaults({:first_name => 'firstly', :last_name => 'lastly', :organization => 'organizationally'})
    end
    it "should generate a hash with DemocracyInAction field names for keys" do
      @defaults['First_Name'].should == 'firstly'
    end
    it "should not allow illegal columns" do
      @defaults.keys.should_not include('Password')
    end
  end
end
