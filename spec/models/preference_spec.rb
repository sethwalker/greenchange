require File.dirname(__FILE__) + '/../spec_helper'

describe Preference do
  it "removes from democracy in action groups if setting to false" do
    p = new_preference :name => "subscribe_to_email_list", :value => "0"
    p.should_receive(:democracy_in_action_proxies).and_return(mock('proxies', :destroy_all => true))
    p.save
  end
  it "removes from democracy in action groups if setting to false and name is symbol" do
    p = new_preference :name => :allow_info_sharing, :value => "0"
    p.should_receive(:democracy_in_action_proxies).and_return(mock('proxies', :destroy_all => true))
    p.save
  end
end
