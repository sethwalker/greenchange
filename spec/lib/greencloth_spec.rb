require File.dirname(__FILE__) + '/../spec_helper'

describe "GreenCloth" do
  it "should format links properly" do
    string = "a url, http://network.greenchange.org/blogs/3307-ecoaction-water-brochure."
    GreenCloth.new(string).to_html.should == %q(<p>a url, <a href="http://network.greenchange.org/blogs/3307-ecoaction-water-brochure">http://network.greenchange.org/blogs/33...</a>.</p>)
  end
end
