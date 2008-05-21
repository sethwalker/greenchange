require File.dirname(__FILE__) + '/../spec_helper'

describe PageUrlHelper do
  describe "page_url" do
    before do
#      @page = create_page
    end
    it "should work for wikis" do
      @page = Tool::TextDoc.create :title => 'title'
      page_url(@page).should == wiki_url(@page)
    end
    it "should work for actions" do
      @page = Tool::ActionAlert.create :title => 'title'
      page_url(@page).should == action_url(@page)
    end
    it "should work for blogs" do
      @page = Tool::Blog.create :title => 'title'
      page_url(@page).should == blog_url(@page)
    end
    it "should work for news" do
      @page = Tool::News.create :title => 'title'
      page_url(@page).should == news_url(@page)
    end
    it "should work for assets" do
      @page = Tool::Asset.create :title => 'title'
      page_url(@page).should == upload_url(@page)
    end
    it "should work for events" do
      @page = Tool::Event.create :title => 'title'
      page_url(@page).should == event_url(@page)
    end
    it "should work for videos" do
      @page = Tool::Video.create :title => 'title'
      page_url(@page).should == video_url(@page)
    end
    it "should work for ranked vote" do
      @page = Tool::RankedVote.create :title => 'title'
      page_url(@page).should == poll_url(@page)
    end
    it "should work for rate many" do
      @page = Tool::RateMany.create :title => 'title'
      page_url(@page).should == survey_url(@page)
    end
    it "should work for task list" do
      @page = Tool::TaskList.create :title => 'title'
      page_url(@page).should == task_url(@page)
    end
    it "should take args ok" do
      @page = Tool::TextDoc.create :title => 'title'
      page_url(@page, :version => '2').should == wiki_url(@page, :version => '2')
    end
    it "should take args ok" do
      @page = Tool::TextDoc.create :title => 'title'
      page_url(@page, :page => 2).should == wiki_url(@page, :page => 2)
    end
  end
end
