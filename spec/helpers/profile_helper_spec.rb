require File.dirname(__FILE__) + '/../spec_helper'
describe ProfileHelper do
  it "should show all available issues" do
    first = mock('first_issue', :id => 1)
    first.should_receive(:name).and_return('first issue')
    second = mock('second_issue', :id => 2)
    second.should_receive(:name).and_return('second issue')
    issues = [first, second]
    Issue.should_receive(:find).and_return(issues)
    text = issue_selector(stub('entity', :issues => []))
    text.should have_tag("input[type=checkbox][name='issues[]']")
  end

end
