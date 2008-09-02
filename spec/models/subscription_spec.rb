require File.dirname(__FILE__) + '/../spec_helper'

describe Subscription do
  before do
    @test_url = 'http://test.org'
    @atom_url = 'http://test_atom.org'
    @wordpress_url = 'http://test-wordpress.org'
    @sub = new_subscription :url => @test_url
  end

  it "records the last time it was updated" do
    time = Time.now
    Time.stub!(:now).and_return time
    @sub.update!
    @sub.last_updated_at.should == time
  end

  it "pulls the feed on create" do
    @sub.stub!(:discover_feed_url).and_return true
    @sub.should_receive(:fetch)
    @sub.save
  end

  it "validates the format of the url" do
    @sub.url = "invalid host . com"
    @sub.stub!(:open).with( @sub.lookup_uri(@sub.url)).and_return File.new("#{RAILS_ROOT}/spec/fixtures/google_feed_find_fail.json")
    @sub.should_not be_valid
  end

  describe "with valid url" do
    before do
      @sub.stub!(:discover_feed_url).and_return true
      @sub.stub!(:open).with(@test_url).and_return File.open("#{RAILS_ROOT}/spec/fixtures/rss_20.rss")
      @sub.stub!(:open).with(@atom_url).and_return File.open("#{RAILS_ROOT}/spec/fixtures/atom_10.xml")
      @sub.stub!(:open).with(@wordpress_url).and_return File.open("#{RAILS_ROOT}/spec/fixtures/wordpress.rss")
    end

    it "gets input from open-uri" do
      @sub.should_receive(:open).and_return File.open("#{RAILS_ROOT}/spec/fixtures/rss_20.rss")
      @sub.fetch
    end

    it "only returns items that are new since the last update" do
      @sub.last_updated_at = Time.mktime 2008, 8, 6
      @sub.fetch.all? {|entry| Time.parse(entry.last_updated) > @sub.last_updated_at}.should be_true
    end

    it "fetched feed create new reposts" do
      @sub.reposts.should_receive :create
      @sub.save!
    end

    it "builds valid reposts" do
      @entries = @sub.fetch
      @sub.reposts.build_from_feed(@entries)
      @sub.reposts.first.should be_valid
    end

    it "does not create duplicate reposts" do
      @sub.save
      lambda {@sub.update!}.should_not change(Tool::Repost, :count)
    end

    describe "when the updated date changes" do
      before do
        Time.stub!(:now).and_return(Time.mktime(2008, 8, 10))
        @sub.save
        @sub.stub!(:open).with(@test_url).and_return File.open("#{RAILS_ROOT}/spec/fixtures/rss_20_updated.rss")
        @sub.instance_variable_set(:@feed, nil)
      end
      it "does not create duplicate reposts when the updated date changes" do
        lambda {@sub.update!}.should_not change(Tool::Repost, :count)
      end

      it "updates existing reposts when the updated date changes" do
        @sub.update!
        repost = Tool::Repost.find :first, :include => {:data => :document_meta}, :conditions => [ 'source_url = ?', "http://www.alternet.org/columnists/story/94128/the_new_face_of_terrorism_a_square_white_guy/"]
        repost.summary.should match(/ontological/)
      end
    end


    describe "repost metadata" do
      before do
        @entry = @sub.entries.first
        @sub.reposts.build_from_feed(@sub.fetch)
        @sub.save
        @sub.last_updated_at = nil
      end
      it "sets repost creator" do
        @sub.reposts.first.data.creator.should == @entry.author
      end

      it "sets repost creator_url" do
        pending "creator urls spottingz :)"
        @sub.reposts.translate(@entry).data.creator_url.should == @sub.fetch.first.helloze?
      end
      it "sets repost source" do
        @sub.reposts.first.data.source.should == @sub.feed.title
      end
      it "sets repost source_url" do
        @sub.reposts.first.data.source_url.should == @sub.fetch.first.url
      end
      it "sets repost published_at" do
        @sub.reposts.first.data.published_at.should == Time.parse(@sub.fetch.first.date_published)
      end
    end
    it "creates items in the order they were published" do
      @sub.save!
      square = Tool::Repost.find( :first, :conditions => [ 'title like ?', "%Square White Guy%" ] )
      palin = Tool::Repost.find( :first, :conditions => [ 'title like ?', "%Disturbing%" ] )
      (palin.created_at > square.created_at).should be_true
    end

    it "parses atom feeds" do
      @sub.url = @atom_url
      @sub.fetch.should_not be_empty
    end

    it "parses wordpress feeds" do
      @sub.url = @wordpress_url
      @sub.save!
    end

    it "should send etags and ifnotmodiedsince headers or something"

  end

  it "discovers existing feeds" do
    @test_discovery_url = 'http://intertwingly.net/blog'
    @test_discovered_url = 'http://intertwingly.net/blog/index.atom'
    @google_feed_url = @sub.lookup_uri(@test_discovery_url)
    @sub.stub!(:open).with(@google_feed_url).and_return File.open("#{RAILS_ROOT}/spec/fixtures/google_feed_find.json")
    @sub.stub!(:open).with(@test_discovered_url).and_return File.open("#{RAILS_ROOT}/spec/fixtures/atom_10.xml")

    @sub.url = @test_discovery_url
    @sub.save
    @sub.url.should == @test_discovered_url
  end
end
