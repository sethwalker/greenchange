class Bookmark < ActiveRecord::Base
  belongs_to :page
  belongs_to :user
  validates_uniqueness_of :page_id, :scope => :user_id, :message => 'is already bookmarked'

  include PageUrlHelper
  def url
    read_attribute('url') || page_url(page)
  end
  
  def external?
    !(url.nil?) && url =~ /^http/

  end

end
