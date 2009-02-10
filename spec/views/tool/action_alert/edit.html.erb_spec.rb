require File.dirname(__FILE__) + '/../../../spec_helper'

describe "action_alerts/edit" do
  it "should have the proper form tag" do
    template.stub!(:current_user).and_return(create_user)
    template.stub!(:form_authenticity_token)
    template.stub!(:render).with(:partial => 'document_meta', :object => nil)
    template.class.__send__(:include, Tool::BaseHelper)
    #assigns[:wiki] = @wiki = ActionAlert.new(:id => 1)
    assigns[:page] = @page = Tool::ActionAlert.create(:title => 'anaction')
    @page.build_data
    render "tool/action_alert/edit"
    response.should have_tag("form[action=?]", action_path(@page))
    response.should have_tag("input[name=_method][value=put]")
  end
end
