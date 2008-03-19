require File.dirname(__FILE__) + '/../../../spec_helper'

describe "action_alert/show" do
  it "should be successful" do
    assigns[:wiki] = assigns[:action_alert] = @wiki = ActionAlert.create
    @wiki.stub!(:document_meta).and_return(DocumentMeta.new(:creator => 'c', :creator_url => 'c_url'))
    render "tool/action_alert/show"
  end
end
