require File.dirname(__FILE__) + '/../../../spec_helper'

describe "action_alerts/edit" do
  it "should have the proper form tag" do
    template.stub!(:current_user).and_return(create_user)
    template.stub_render(:partial => 'document_meta', :object => nil)
    assigns[:wiki] = @wiki = ActionAlert.new(:id => 1)
    assigns[:page] = @page = Tool::ActionAlert.create(:title => 'anaction')
    render "tool/action_alert/edit"
    response.should have_tag("form[action=?]", action_path(@page))
    response.should have_tag("input[name=_method][value=put]")
  end
end
