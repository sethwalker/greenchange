class Event < ActiveRecord::Base
  include GeoKit::Geocoders  # for geocoding

  before_save :save_latitude_and_longitude  # attempt to geocode address
  before_save :check_time_conversion

  has_one :page, :as => :data
  format_attribute :description

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

  def to_local(time )
    TzTime.new(TimeZone[time_zone].utc_to_local(time), TimeZone[time_zone] )
  end

  def date_start
    page.starts_at.loc('%Y-%m-%d') if page && page.starts_at
  end
  def date_end
    page.ends_at.loc('%Y-%m-%d') if page && page.ends_at
  end
  def hour_start
    page.starts_at.loc('%I:%M %p') if page && page.starts_at
  end
  def hour_end
    page.ends_at.loc('%I:%M %p') if page && page.ends_at
  end
  attr_writer :date_start, :date_end, :hour_start, :hour_end
  attr_accessor :state_other

  before_validation {|event| state = @state_other if @state_other && (state == 'Other' || state.blank? ) }

  def check_time_conversion
    # greenchange_note: HACK: all day events will be put in as UTC
    # noon (note: there is no 'UTC' timezone available, so we are
    # going to use 'London' for zero GMT offset as a hack for now)
    # so that when viewed in calendars or lists, the events will
    # always show up on the appropriate day ie, St. Patrick's day
    # should always be on the 17th of March regardless of my frame
    # of reference.  Also, since we have a programmatic flag to
    # identify all day events, this hack can be removed / migrated
    # later to any required handling of all day events that might be
    # more complex on the fetching side.
    if self.is_all_day?
      @hour_start = "12:00"
      @hour_end = "12:00"
      self.time_zone = "London"
    end

    start_datetimes = [ @date_start, @hour_start ]
    end_datetimes = [ @date_end, @hour_end ]
    return true if [ start_datetimes, end_datetimes].flatten.empty?
    self.page.starts_at = TzTime.new( Time.parse(start_datetimes.compact.join(' ')), TimeZone[self.time_zone] ).utc
    self.page.ends_at = TzTime.new( Time.parse(end_datetimes.compact.join(' ')), TimeZone[self.time_zone] ).utc
    
#    page.save
    return true
  end

    
end
