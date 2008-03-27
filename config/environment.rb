
# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0.2'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

#### ENUMERATIONS ##############

# levels of page access
ACCESS = {
 :admin => 1,
 :change => 2,
 :edit => 2, 
 :view => 3,
 :read => 3
}.freeze

# do this early because environments/*.rb need it
require 'crabgrass_config'
Crabgrass::Config.host = 'greenchange.staging.radicaldesigns.org'

########################################################################
### BEGIN CUSTOM OPTIONS

Crabgrass::Config.site_name         = 'planet.unicorn' 
Crabgrass::Config.host              = 'greenchange.staging.radicaldesigns.org'
Crabgrass::Config.email_sender      = 'planet_unicorn@radicaldesigns.org'

SECTION_SIZE = 29 # the default size for pagination sections

AVAILABLE_PAGE_CLASSES = %w[
  Message Discussion TextDoc RateMany RankedVote TaskList Asset Blog ActionAlert News ExternalVideo Event
]

### END CUSTOM OPTIONS
########################################################################


Rails::Initializer.run do |config|
  #autoload gems in vendor
  config.load_paths += Dir["#{RAILS_ROOT}/vendor/gems/**"].map do |dir| 
    File.directory?(lib = "#{dir}/lib") ? lib : dir
  end

  #load models in subdirectories
  config.load_paths += %w(associations discussion chat profile).collect do |dir|
    "#{RAILS_ROOT}/app/models/#{dir}"
  end
  
  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  config.active_record.observers = [:user_observer, :asset_observer]

#  config.action_controller.session_store = :p_store
  #
  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_crabgrass_session',
    :secret      => '9ce1ae3f9d26b56cf9fc7682635486898b3450a9e0116ea013a7a14dd24833cab5fafcd17f2c555f7663c0524a938e5ed6df2af8bf134d3959fc8ac3214fa8c7'
  }
  
  # Make Active Record use UTC-base instead of local time
  config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
end

require 'enhanced_migrations'
require 'has_finder'
require 'tagging_extensions'
require 'textile_editor_form_builder_helper'


#### SESSION HANDLING ##############

#ActionController::Base.session_options[:session_expires] = 3.hours.from_now
#if File.directory? '/dev/shm/'
#  ActionController::Base.session_options[:tmpdir] = '/dev/shm/'
#end
  
#### CUSTOM EXCEPTIONS #############

class PermissionDenied < Exception; end    # the user does not have permission to do that.
class ErrorMessage < Exception; end        # just show a message to the user.
class AssociationError < Exception; end    # thrown when an activerecord has made a bad association (for example, duplicate associations to the same object).

#### CORE LIBRARIES ################

require "#{RAILS_ROOT}/lib/extends_to_core.rb"
require "#{RAILS_ROOT}/lib/extends_to_active_record.rb"
require "#{RAILS_ROOT}/lib/greencloth/greencloth.rb"
require "#{RAILS_ROOT}/lib/misc.rb"
require "#{RAILS_ROOT}/lib/path_finder.rb"

#### TOOLS #########################

# pre-load the tools:
Dir.glob("#{RAILS_ROOT}/**/app/models/tool/*.rb").each do |toolfile|
  require toolfile
end
# a static array of tool classes:
TOOLS = Tool.constants.collect{|tool|Tool.const_get(tool)}.freeze

AVAILABLE_PAGE_CLASSES.collect!{|i|Tool.const_get(i)}.freeze

#### ASSETS ########################

#Asset.file_storage = "/crypt/files"

# force a new css and javascript url whenever any of the said
# files have a new mtime. this way, no need to expire
# static cache of css and js.
CSS_VERSION = max_mtime("#{RAILS_ROOT}/public/stylesheets/*.css")
JAVASCRIPT_VERSION = max_mtime("#{RAILS_ROOT}/public/javascripts/*.js")

#### TIME ##########################

ENV['TZ'] = 'UTC' # for Time.now
DEFAULT_TZ = 'Pacific Time (US & Canada)'

#### USER INTERFACE HELPERS ########

FightTheMelons::Helpers::FormMultipleSelectHelperConfiguration.outer_class = 'plainlist'

#include all files in the initializers folder ( TODO remove in Rails 2 branch )
Dir.entries( "#{RAILS_ROOT}/config/initializers/" ).each do |filename |
  require "#{RAILS_ROOT}/config/initializers/#{filename}" if filename =~ /\.rb$/ 
end


WillPaginate::ViewHelpers.pagination_options[:renderer] = 'CrabgrassLinkRenderer'
WillPaginate::ViewHelpers.pagination_options[:prev_label] = '&laquo; previous'
WillPaginate::ViewHelpers.pagination_options[:next_label] = 'next &raquo;'
#
# These defaults are used in GeoKit::Mappable.distance_to and in acts_as_mappable
GeoKit::default_units = :miles
GeoKit::default_formula = :sphere

# This is the timeout value in seconds to be used for calls to the geocoder web
# services.  For no timeout at all, comment out the setting.  The timeout unit
# is in seconds. 
GeoKit::Geocoders::timeout = 3

# These settings are used if web service calls must be routed through a proxy.
# These setting can be nil if not needed, otherwise, addr and port must be 
# filled in at a minimum.  If the proxy requires authentication, the username
# and password can be provided as well.
GeoKit::Geocoders::proxy_addr = nil
GeoKit::Geocoders::proxy_port = nil
GeoKit::Geocoders::proxy_user = nil
GeoKit::Geocoders::proxy_pass = nil

# This is your yahoo application key for the Yahoo Geocoder.
# See http://developer.yahoo.com/faq/index.html#appid
# and http://developer.yahoo.com/maps/rest/V1/geocode.html
GeoKit::Geocoders::yahoo = 'REPLACE_WITH_YOUR_YAHOO_KEY'
    
# This is your Google Maps geocoder key. 
# See http://www.google.com/apis/maps/signup.html
# and http://www.google.com/apis/maps/documentation/#Geocoding_Examples
#GeoKit::Geocoders::google = 'REPLACE_WITH_YOUR_GOOGLE_KEY'

# the key given here is appropriate for http://localhost/
#GeoKit::Geocoders::google = 'ABQIAAAATL4sfiJFXUFfYtomrKYcMRT2yXp_ZAY8_ufC3CFXhHIE1NvwkxSgdzNqmW5nuNCkPicJS8sOhHTE4w'

# Here's a key for http://localhost:3000
GeoKit::Geocoders::google = 'ABQIAAAA3HdfrnxFAPWyY-aiJUxmqRTJQa0g3IQ9GZqIMmInSLzwtGDKaBQ0KYLwBEKSM7F9gCevcsIf6WPuIQ'

# This is your username and password for geocoder.us.
# To use the free service, the value can be set to nil or false.  For 
# usage tied to an account, the value should be set to username:password.
# See http://geocoder.us
# and http://geocoder.us/user/signup
GeoKit::Geocoders::geocoder_us = false 

# This is your authorization key for geocoder.ca.
# To use the free service, the value can be set to nil or false.  For 
# usage tied to an account, set the value to the key obtained from
# Geocoder.ca.
# See http://geocoder.ca
# and http://geocoder.ca/?register=1
GeoKit::Geocoders::geocoder_ca = false

# This is the order in which the geocoders are called in a failover scenario
# If you only want to use a single geocoder, put a single symbol in the array.
# Valid symbols are :google, :yahoo, :us, and :ca.
# Be aware that there are Terms of Use restrictions on how you can use the 
# various geocoders.  Make sure you read up on relevant Terms of Use for each
# geocoder you are going to use.
GeoKit::Geocoders::provider_order = [:google,:us]
