require File.dirname(__FILE__) + '/../../../spec_helper'

describe "tasklist/_task" do
  it "should render" do
    assigns[:page] = Tool::TaskList.create :title => 'atask'
    task = create_task
    template.expect_render :partial => 'tool/tasklist/task_show', :locals => {:task => task}
    render :partial => "tool/tasklist/task", :locals => {:task => task}
  end
end
