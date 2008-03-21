require File.dirname(__FILE__) + '/../../../spec_helper'

describe "ranked_vote/_possible_edit" do
  before do
    @page = create_page(:type => 'Tool::RankedVote')
    @possible = create_possible
  end
  it "should render" do
    assigns[:page] = @page
    render :partial => "tool/ranked_vote/possible_edit", :locals => {:possible => Poll::Possible.new}
  end
end
