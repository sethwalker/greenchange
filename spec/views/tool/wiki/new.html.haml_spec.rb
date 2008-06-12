require File.dirname(__FILE__) + '/../../../spec_helper'

describe "wiki/new" do
  before do
    template.stub!(:current_user).and_return create_user
    template.stub!(:form_authenticity_token)
    assigns[:page] = @page = Tool::TextDoc.new
    assigns[:data] = @wiki = @page.build_data(:body => 'new page')
    template.class.__send__(:include, Tool::BaseHelper)
    #template.stub!(:header_for_page_create)
    render "tool/wiki/new"
  end
  it "should render" do
    response.should be_success
  end
  it "should have page fields" do
    response.should have_tag('input[name^="page"]')
  end
  it "should have data fields" do
    response.should have_tag('input[name*="page_data"]')
  end
end
