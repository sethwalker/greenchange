require File.dirname(__FILE__) + '/../../spec_helper'

describe "DemocracyInAction initializer" do
  it "should load without error" do
    Profile.included_modules.should include(DemocracyInAction::Mirroring::ActiveRecord)
  end

ENV['DIA_USER'] = "test"
ENV['DIA_PASS'] = "test"
ENV['DIA_ORG'] = "962"

  #should probably move this
  if !ENV['DIA_USER'].empty? && !ENV['DIA_PASS'].empty? && !ENV['DIA_ORG'].empty?
    describe "when CONNECTING TO DIA!!!" do
      before do
        DemocracyInAction::Mirroring.__send__ :class_variable_set, :@@api, nil
        DemocracyInAction.configure do
          auth.username = ENV['DIA_USER']
          auth.password = ENV['DIA_PASS']
          auth.org_key  = ENV['DIA_ORG']
        end
        DemocracyInAction::API.stub!(:disabled?).and_return(false)
      end
      after do
        DemocracyInAction.configure do
          auth.username = auth.password = auth.org_key = nil
        end
        DemocracyInAction::API.stub!(:disabled?).and_return(true)
        DemocracyInAction::Mirroring.__send__ :class_variable_set, :@@api, nil
      end

      before do

require 'ruby-debug'
debugger

        @timestamp ||= Time.now.to_i
        @timestamp += 1
        email = "greenchange_test_#{@timestamp}@radicaldesigns.org"
        @user = new_user(:email => email, :private_profile => nil)
        @user.build_private_profile(:first_name => 'firstly', :last_name => 'lastly', :organization => 'organizationally')
        @user.save
        @sharing_pref = @user.preferences.create(:name => 'allow_info_sharing', :value => true)
        @subscription_pref = @user.preferences.create(:name => 'email_subscription_list', :value => true)
        #@proxy = @user.private_profile.democracy_in_action_proxies.find_by_remote_table('supporter')
        @proxy = @sharing_pref.democracy_in_action_proxies.find_by_remote_table('supporter_groups')
        @proxy = @subscription_pref.democracy_in_action_proxies.find_by_remote_table('supporter_groups')
      end

      it "should save a proxy" do
        @proxy.should_not be_nil
      end

      it "the proxy should have a remote key" do
        @proxy.remote_key.should_not be_nil
      end

      describe "DIA preferenes" do
        before do
          @group_proxies = []
          @user.preferences.each do |pref|
            @group_proxy = pref.democracy_in_action_proxies.find_by_remote_table('supporter_groups')
            @group_proxies << @group_proxy if @group_proxy
          end
        end

        it "should add the supporter to the DIA email subscription group" do
          #@remote_group = DemocracyInAction::Mirroring.api.get('group', @proxy_group.remote_key).first
        end

        it "should add the supporter to the allow info sharing group" do
        end
      end

      describe "the DIA record" do
        before do
          @remote = DemocracyInAction::Mirroring.api.get('supporter', @proxy.remote_key).first
        end
        it "should have the first name" do
          @remote['First_Name'].should == 'firstly'
        end
        it "should have the last name" do
          @remote['Last_Name'].should == 'lastly'
        end
        it "should have organization" do
          @remote['Organization'].should == 'organizationally'
        end
      end
    end
  end
end
