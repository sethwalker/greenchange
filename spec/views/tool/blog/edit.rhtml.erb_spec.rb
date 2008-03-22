require File.dirname(__FILE__) + '/../../../spec_helper'

describe "blogs/edit" do
  it "should have the proper form tag" do
    template.stub_render(:partial => 'document_meta', :object => nil)
    assigns[:wiki] = @wiki = Blog.new(:id => 1)
    assigns[:page] = @page = Tool::Blog.create(:title => 'ablog')
    render "tool/blog/edit"
    response.should have_tag("form[action=?]", blog_path(@page))
    response.should have_tag("input[name=_method][value=put]")
  end
end
