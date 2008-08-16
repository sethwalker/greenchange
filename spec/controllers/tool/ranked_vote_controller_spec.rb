require File.dirname(__FILE__) + '/../../spec_helper'

describe Tool::RankedVoteController do
  before do
    login_user(@user = new_user)
    @page = create_page(:type => 'Tool::RankedVote')
    @page.data = Poll::Poll.new
    controller.stub!(:fetch_page_data)
    controller.instance_variable_set(:@page, @page)
    controller.stub!(:login_or_public_page_required).and_return(true)
    controller.stub!(:authorized?).and_return(true)
  end
  describe "show" do
    it "should redirect if no possibles" do
      get :show, :id => @page.to_param
      response.redirect_url.should == edit_poll_url(@page)
    end
    it "should be successful if there are possibles" do
      @page.data.possibles.stub!(:any?).and_return(true)
      get :show, :id => @page.to_param
      response.should be_success
    end
  end
end
