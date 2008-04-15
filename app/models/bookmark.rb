class Bookmark < ActiveRecord::Base
  belongs_to :page
  belongs_to :user

  include PageUrlHelper
  def url
    read_attribute('url') || page_url(page)
  end
  
  def external?
    !(url.nil?) && url =~ /^http/

  end

end
