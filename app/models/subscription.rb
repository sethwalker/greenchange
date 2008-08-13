class Subscription < ActiveRecord::Base
  belongs_to :user
  after_create :update!
  before_validation :discover_feed_url
  validates_uniqueness_of :url, :message => "has already been subscribed by another user"

  has_many :reposts, :class_name => "Tool::Repost" do
    def update_from_feed( updated_entries, existing )
      return if updated_entries.empty?
      updated_entries.each do |entry|
        post = existing.find {|p| p.data.source_url == entry.url }
        post.attributes = translate(entry)
        post.save 
      end
    end

    def create_from_feed(feed_entries)
      create feed_entries.map { |e| translate(e) }
    end

    def build_from_feed(feed_entries)
      build feed_entries.map { |e| translate(e) }
    end

    def translate(e)
      feed_host = URI.parse( proxy_owner.feed.url ).host
      item_url = (e.url.include?(feed_host) || e.url =~ /^http:\/\//) ? e.url : "http://#{feed_host}#{e.url}"
      { :title => e.title, :summary => e.description, :page_data => { :body => e.content, :document_meta_data => { :creator => e.author, :source_url => item_url, :source => proxy_owner.feed.title, :published_at => e.date_published } }, :created_by => proxy_owner.user, :public => true }
    end
  end

  def update!
    fetched = fetch
    return update_attribute( :last_updated_at, Time.now ) if fetched.empty?

    existing_items = existing_reposts( fetched.map(&:url))
    existing_urls = existing_items.map { |ex| ex.data.source_url }
    updated_fetched, new_fetched = fetched.partition { |fe| existing_urls.include?( fe.url )}
    reposts.create_from_feed new_fetched unless new_fetched.empty?
    reposts.update_from_feed( updated_fetched, existing_items ) unless updated_fetched.empty?
    update_attribute :last_updated_at, Time.now
  end

  def existing_reposts(urls)
    Tool::Repost.find(:all, :include => {:data => :document_meta}, :conditions => ["pages.subscription_id = ? and document_metas.source_url in (?)", id, urls])
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

  def lookup_uri(uri)
    "http://ajax.googleapis.com/ajax/services/feed/lookup?q=#{CGI::escape(uri)}&v=1.0"
  end

  def discover_feed_url
    result = ActiveSupport::JSON.decode(open(lookup_uri(url)).read)

    unless result['responseData'] and result['responseData']['url']
      errors.add :url, "not valid" and return false
    end

    result = result['responseData']
    if result['url'] and result['url'] != result['query']
      self.url = result['url']
    end
  end
end
