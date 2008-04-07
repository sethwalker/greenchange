require File.dirname(__FILE__) + '/../../spec_helper'

describe "DemocracyInAction initializer" do
  it "should load without error" do
    Profile.included_modules.should include(DemocracyInAction::Mirroring::ActiveRecord)
  end

  #should probably move this
  if ENV['DIA_USER'] && ENV['DIA_PASS'] && ENV['DIA_ORG']
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
        @timestamp ||= Time.now.to_i
        @timestamp += 1
        email = "greenchange_test_#{@timestamp}@radicaldesigns.org"
        @user = new_user(:email => email, :private_profile => nil)
        @user.build_private_profile(:first_name => 'firstly', :last_name => 'lastly', :organization => 'organizationally')
        @user.save
        @proxy = @user.private_profile.democracy_in_action_proxies.find_by_remote_table('supporter')
      end

      it "should save a proxy" do
        @proxy.should_not be_nil
      end

      it "the proxy should have a remote key" do
        @proxy.remote_key.should_not be_nil
      end

      describe "the DIA record" do
        before do
          @remote = DemocracyInAction::Mirroring.api.get('supporter', @proxy.remote_key).first
        end
        it "should have the first name" do
          @remote['First_Name'].should == 'firstly'
        end
        it "should have the first name" do
          @remote['Last_Name'].should == 'lastly'
        end
        it "should have the first name" do
          @remote['Organization'].should == 'organizationally'
        end
      end

    end
  end
end
