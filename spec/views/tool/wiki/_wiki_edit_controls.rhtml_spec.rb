require File.dirname(__FILE__) + '/../../../spec_helper'

describe "wiki/_wiki_edit_controls" do
  before do
    template.stub!(:current_user).and_return(@user = create_user)
    assigns[:page] = @page = create_page(:type => 'Tool::TextDoc')
    assigns[:wiki] = @wiki = Wiki.new
  end
  it "should render" do
    render "tool/wiki/_wiki_edit_controls"
  end
  it "should show break lock if locked" do
    @wiki.should_receive(:editable_by?).and_return(false)
    render "tool/wiki/_wiki_edit_controls"
    response.should have_tag("a[href=?]", break_lock_wiki_url(@page))
  end
end
