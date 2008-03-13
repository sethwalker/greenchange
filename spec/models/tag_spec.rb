require File.dirname(__FILE__) + '/../spec_helper'

describe Tag do

  it "should save tags" do
    p = create_page
    p.tag_with "pale imperial"
    Page.find(p.id).tags.to_s.should == "imperial pale"
  end
  
end
