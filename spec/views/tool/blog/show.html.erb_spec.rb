require File.dirname(__FILE__) + '/../../../spec_helper'

describe "blog/show" do
  it "should be successful" do
    assigns[:wiki] = assigns[:blog] = @wiki = Blog.create
    assigns[:page] = @page = Tool::Blog.create(:title => 'ablog')
    @page.data = @wiki
    render "tool/blog/show"
  end
end
