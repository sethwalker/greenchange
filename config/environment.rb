
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

# do this early because production uses it for https_only
require 'crabgrass_config'

SECTION_SIZE = 29 # the default size for pagination sections

AVAILABLE_PAGE_CLASSES = %w[
  Discussion TextDoc RateMany RankedVote TaskList Asset Blog ActionAlert News ExternalVideo Event Image Video Audio
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
  config.active_record.observers = :user_observer, :asset_observer

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
  config.after_initialize do
    #### CORE LIBRARIES ################

    require "#{RAILS_ROOT}/lib/extends_to_core.rb"
    require "#{RAILS_ROOT}/lib/extends_to_active_record.rb"
    require "#{RAILS_ROOT}/lib/greencloth/greencloth.rb"
    require "#{RAILS_ROOT}/lib/misc.rb"
    require "#{RAILS_ROOT}/lib/path_finder.rb"
  end
end

require 'enhanced_migrations'
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
class RecordLockedError < Exception; end

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
#CSS_VERSION = max_mtime("#{RAILS_ROOT}/public/stylesheets/*.css")
#JAVASCRIPT_VERSION = max_mtime("#{RAILS_ROOT}/public/javascripts/*.js")

#### TIME ##########################

ENV['TZ'] = 'UTC' # for Time.now
#DEFAULT_TZ = 'Pacific Time (US & Canada)'

