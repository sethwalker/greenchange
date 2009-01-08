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

    # for manipulating created_at timestamps to be in the order of date_published
    def now
      @now ||= Time.now
      @now = @now + 1.second
    end

    def translate(e)
      feed_host = URI.parse( proxy_owner.feed.url.strip ).host
      item_url = (e.url.include?(feed_host) || e.url =~ /^https?:\/\//) ? e.url : "http://#{feed_host}#{e.url}"
      date_published = e.date_published.is_a?(Time) ? e.date_published : Time.parse(e.date_published) if e.date_published
      { :title => e.title, :summary => e.description, :page_data => { :body => e.content, :document_meta_data => { :creator => e.author, :source_url => item_url, :source => proxy_owner.feed.title, :published_at => date_published } }, :created_by => proxy_owner.user, :public => true, :created_at => self.now }
    end
  end

  def update!
    fetched = fetch
    return update_attribute( :last_updated_at, Time.now ) if fetched.empty?

    existing_items = existing_reposts( fetched.map(&:url))
    existing_urls = existing_items.map { |ex| ex.data.source_url }
    updated_fetched, new_fetched = fetched.partition { |fe| existing_urls.include?( fe.url )}
    updated_fetched = updated_fetched.select {|fe| !fe.last_updated.blank?}
    reposts.create_from_feed new_fetched unless new_fetched.empty?
    reposts.update_from_feed( updated_fetched, existing_items ) unless updated_fetched.empty?
    update_attribute :last_updated_at, Time.now
  end

  def existing_reposts(urls)
    Tool::Repost.find(:all, :include => {:data => :document_meta}, :conditions => ["pages.subscription_id = ? and document_metas.source_url in (?)", id, urls])
  end

  def fetch
    return entries unless last_updated_at
    entries.select do |entry|
      entry_last_updated = entry.last_updated.is_a?(Time) ? entry.last_updated : Time.parse(entry.last_updated)
      entry_last_updated > last_updated_at 
    end
  rescue SocketError
  end

  def feed
    return @feed if @feed
    @feed = FeedNormalizer::FeedNormalizer.parse open(url)
    @feed.clean! if @feed
    @feed
  rescue OpenURI::HTTPError
    nil
  end

  def entries
    e = feed.try(:entries) || []
    return e if e.empty?
    if e.first.date_published
      e.sort_by {|entry| entry.date_published.to_time }
    else
      e.reverse
    end
  end

  def lookup_uri(uri)
     escaped_uri = URI.escape(uri, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    "http://ajax.googleapis.com/ajax/services/feed/lookup?q=#{escaped_uri}&v=1.0"
  end

  def discover_feed_url
    result = ActiveSupport::JSON.decode(open(lookup_uri(url)).read)

    unless result['responseData'] and result['responseData']['url']
      errors.add :url, "not valid" and return false
    end

    result = result['responseData']
    # for feeds that include '=', google translates to encoded 
    # and this is the only way i've found to decode
    result_url = result['url'].gsub('\\u003d', '=')
    query_url = result['query'].gsub('\\u003d', '=')
    if result_url and result_url != query_url
      self.url = result_url
    end
  end
end
