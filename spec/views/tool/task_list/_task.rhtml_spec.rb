require File.dirname(__FILE__) + '/../../../spec_helper'

describe "tasklist/_task" do
  it "should render" do
    assigns[:page] = Tool::TaskList.create :title => 'atask'
    task = create_task
    template.expect_render :partial => 'tool/task_list/task_show', :locals => {:task => task}
    render :partial => "tool/task_list/task", :locals => {:task => task}
  end
end
