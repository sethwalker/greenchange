class Subscription < ActiveRecord::Base
  belongs_to :user
  after_create :update!
  validate :valid_url
  has_many :reposts, :class_name => "Tool::Repost" do
    def build_from_feed(feed_entries)
      build feed_entries.map { |e| translate(e) }
    end
    def create_from_feed(feed_entries)
      create feed_entries.map { |e| translate(e) }
    end
    def translate(e)
      { :title => e.title, :summary => e.description, :page_data => { :body => e.content, :document_meta_data => { :creator => e.author, :source_url => e.url, :source => proxy_owner.feed.title, :published_at => e.date_published } }, :created_by => proxy_owner.user }
    end
  end

  def update!
    entries = fetch
    reposts.create_from_feed entries unless entries.empty?
    self.last_updated_at = Time.now
  end

  def fetch
    return entries unless last_updated_at
    entries.select{ |entry| entry.last_updated > last_updated_at }
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
