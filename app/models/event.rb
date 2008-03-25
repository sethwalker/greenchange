class Event < ActiveRecord::Base
  include GeoKit::Geocoders  # for geocoding

  before_save :save_latitude_and_longitude  # attempt to geocode address

  has_many :pages, :as => :data
  format_attribute :description

  def page
    pages.first || parent_page
  end

  def page=(p)
    @page = p
  end

  def save_latitude_and_longitude
    address = "#{self.address1},#{self.address2},#{self.city},#{self.state},#{self.postal_code},#{self.country}"
    location = GoogleGeocoder.geocode(address)
    coords = location.ll.scan(/[0-9\.\-\+]+/)
    if coords.length == 2
      self.longitude = coords[1]
      self.latitude = coords[0]
    else
      self.longitude = nil
      self.latitude = nil
    end
  end

  protected

  def default_group_name
    if page and page.group_name
      page.group_name
    else
      'page'
    end
  end
end
