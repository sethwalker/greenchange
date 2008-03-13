require File.dirname(__FILE__) + '/../spec_helper'

describe "Messages (in general)" do

  before do
    @sender = create_valid_user({:login => 'sender'})
    @recipients = [
      create_valid_user({:login => 'recipient_1'}),
      create_valid_user({:login => 'recipient_2'})
    ]

    @page = Page.make :private_message, :to => @recipients, :from => @sender,
      :title => 'hi there', :body => 'whatcha doing?'
  end

  it "should be a valid page" do
    @page.valid?.should be_true
  end

  it "should have one valid discussion post" do
    @page.discussion.valid?.should be_true
    @page.discussion.posts.size.should == 1 
    @page.discussion.posts.first.valid?.should be_true
  end

  it "should save posts" do
    @page.save!
    @page = Page.find(@page.id)
    @page.discussion.posts.size.should == 1
  end
end

