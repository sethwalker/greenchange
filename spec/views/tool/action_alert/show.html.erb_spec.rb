require File.dirname(__FILE__) + '/../../../spec_helper'

describe "action_alert/show" do
  it "should be successful" do
    @page = Tool::ActionAlert.create :title => 'cheezies'
    @wiki = @page.build_data
    @wiki.document_meta = (DocumentMeta.new(:creator => 'c', :creator_url => 'c_url'))
    @page.stub!(:data).and_return(@wiki)
    assigns[:page] = @page
    #assigns[:wiki] = assigns[:action_alert] = @wiki = ActionAlert.create
    render "tool/action_alert/show"
  end
end
