class Subscription < ActiveRecord::Base
  belongs_to :user
  after_create :update!
  validate :valid_url
  has_many :reposts, :class_name => "Tool::Repost" do

    def update_from_feed( updated_entries, create = false )
      return if updated_entries.empty?
      updated_entries.each do |entry|
        post = @posts.find {|p| p.data.source_url == entry[:page_data][:document_meta_data][:source_url]}
        post.attributes = entry
        post.save if create
      end
    end

    def create_from_feed(feed_entries)
      build_from_feed(feed_entries, true )
    end
    def build_from_feed(feed_entries, create = false)
      @urls = @posts = nil
      @entries = feed_entries
      updated_entries, new_entries = feed_entries.partition {|e| updated?(e) }
      [new_entries, updated_entries].each {|entries| entries.map! { |e| translate(e) } }
      update_from_feed( updated_entries, create )
      if create
        create new_entries
      else
        build new_entries
      end
    end

    def existing_posts
      @posts ||= Tool::Repost.find(:all, :include => {:data => :document_meta}, :conditions => ["pages.subscription_id = ? and document_metas.source_url in (?)", proxy_owner.id, @entries.map(&:url)])
    end

    def existing_urls
      @urls ||= existing_posts.map {|p| p.data.source_url }
    end

    def updated?(entry)
      existing_urls.include?(entry.url)
    end


    def translate(e)
      { :title => e.title, :summary => e.description, :page_data => { :body => e.content, :document_meta_data => { :creator => e.author, :source_url => e.url, :source => proxy_owner.feed.title, :published_at => e.date_published } }, :created_by => proxy_owner.user }
    end
  end

  def update!
    entries = fetch
    reposts.create_from_feed entries unless entries.empty?
    update_attribute :last_updated_at, Time.now
  end

  def fetch
    return entries unless last_updated_at
    entries.select {|entry| entry.last_updated > last_updated_at }
  rescue SocketError
  end

  def feed
    @feed ||= FeedNormalizer::FeedNormalizer.parse open(url)
  end

  def entries
    feed.entries
  end

  def valid_url
    test_uri = URI.parse url
    open( test_uri )
  rescue
    errors.add :url, "not valid"
  end
end
