require File.dirname(__FILE__) + '/../../../spec_helper'

describe "actions/new" do
  before do
    template.stub!(:current_user).and_return create_user
    template.stub!(:form_authenticity_token)
    assigns[:page] = @page = Tool::ActionAlert.new
    template.class.__send__(:include, Tool::BaseHelper)
    @page.build_data
    #assigns[:wiki] = @wiki = @page.build_data(:body => 'new page')
    #template.stub!(:header_for_page_create)
    render "tool/action_alert/new"
  end
  it "should render" do
    response.should be_success
  end
  it "should have page fields" do
    response.should have_tag('input[name^="page"]')
  end
  it "should have wiki fields" do
    response.should have_tag('input[name*="page_data"]')
  end
end
