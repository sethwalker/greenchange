ENV["RAILS_ENV"] = "test"
plugin_spec_dir = File.dirname(__FILE__)
require File.expand_path(plugin_spec_dir + "/../../../../config/environment")
require 'spec'
require 'spec/rails'
require 'pp'

config = YAML::load(IO.read(plugin_spec_dir + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(plugin_spec_dir + "/debug.log")
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite3'])

ActiveRecord::Migration.suppress_messages do
  load(plugin_spec_dir + "/schema.rb") if File.exist?(plugin_spec_dir + "/schema.rb")
  load(plugin_spec_dir + "/../generators/democracy_in_action_migration/templates/install_democracy_in_action.rb")
  InstallDemocracyInAction.up
end


Object.remove_class User if Object.const_defined?(:User)
class User < ActiveRecord::Base
end

DemocracyInAction::API.stub!(:disabled?).and_return(true)
