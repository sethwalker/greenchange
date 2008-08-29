require File.dirname(__FILE__) + '/../spec_helper'
describe IconHelper do

  describe 'pages' do

    describe 'CSS page type' do
      it "should match class names to page types" do
        helper.css_page_type( Tool::Blog.new ).should match(/blog/)
      end
      it "should do this for wikis" do
        helper.css_page_type( Tool::TextDoc.new ).should match(/wiki/)
      end
    end

    describe "html options for icon" do
      it "should give a wiki icon" do
        helper.html_options_for_icon_for( Tool::TextDoc.new )[:class].should match(/wiki/)
      end
    end
  end
end
