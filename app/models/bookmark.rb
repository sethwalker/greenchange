class Bookmark < ActiveRecord::Base
  belongs_to :page
  belongs_to :user

  def url
    read_attribute('url') || page.url
  end
end
