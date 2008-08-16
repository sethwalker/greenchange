require File.dirname(__FILE__) + '/../../spec_helper'

describe "DemocracyInAction initializer" do
  it "should load without error" do
    Profile.included_modules.should include(DemocracyInAction::Mirroring::ActiveRecord)
  end

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
        UserMailer.stub!(:deliver_signup_notification).and_return(true)
      end
      after do
        DemocracyInAction.configure do
          auth.username = auth.password = auth.org_key = nil
        end
        DemocracyInAction::API.stub!(:disabled?).and_return(true)
        DemocracyInAction::Mirroring.__send__ :class_variable_set, :@@api, nil
      end

      describe "democracy in action proxy" do
        before do
          @timestamp ||= Time.now.to_i
          @timestamp += 1
          login = "greenchange_test_#{@timestamp}"
          email = "#{login}_#{@timestamp}@radicaldesigns.org"
          @user = create_user(:email => email)
          @user.private_profile.update_attributes(:first_name => 'firstly', :last_name => 'lastly', :organization => 'organizationally', :entity => @user)
          @profile_proxy = @user.private_profile.democracy_in_action_proxies.find_by_remote_table('supporter')
        end

        describe "DIA supporter" do
          before do
            @proxy = @user.private_profile.democracy_in_action_proxies.find_by_remote_table('supporter')
            @remote_user = DemocracyInAction::Mirroring.api.get('supporter', @proxy.remote_key).first
          end
          it "should have the first name" do
            @remote_user['First_Name'].should == 'firstly'
          end
          it "should have the last name" do
            @remote_user['Last_Name'].should == 'lastly'
          end
          it "should have organization" do
            @remote_user['Organization'].should == 'organizationally'
          end
          it "should have organization" do
            @remote_user['Source_Details'].should == 'network'
          end
        end

        it "should save a proxy" do
          @profile_proxy.should_not be_nil
        end

        it "the proxy should have a remote key" do
          @profile_proxy.remote_key.should_not be_nil
        end

        describe "allow_info_sharing preference" do
          before do
            @pref = @user.preferences.create(:name => 'allow_info_sharing', :value => "1")
            @pref_proxy = @pref.democracy_in_action_proxies.find_by_remote_table('supporter_groups')
          end

          it "should have a proxy" do
            @pref_proxy.should_not be_nil
          end

          it "the proxy should have a remote key" do
            @pref_proxy.remote_key.should_not be_nil
          end

          describe "DIA record" do
            before do
              @group_remote = DemocracyInAction::Mirroring.api.get('supporter_groups', @pref_proxy.remote_key).first
            end

            it "should be tied to the DIA supporter" do
              @group_remote['supporter_KEY'].should == @profile_proxy.remote_key.to_s
            end

            it "should be added to allow_info_sharing DIA group" do
              @group_remote['groups_KEY'].should == Crabgrass::Config.dia_allow_info_sharing_group_id.to_s
            end
          end
        end
      end
    end
  end
end

=begin
      describe "DIA subscribe to email list" do
        before do
          @pref = @user.preferences.create(:name => 'subscribe_to_email_list', :value => true)
          @group_proxy = @pref.democracy_in_action_proxies.find_by_remote_table('supporter_groups')
        end
      end
=end
