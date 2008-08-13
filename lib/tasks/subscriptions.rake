require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'
require File.expand_path(File.dirname(__FILE__) + "/../../config/environment")

namespace :subscriptions do
  desc "Update all existing subscriptions with new content" 
  task :update do
    ThinkingSphinx.deltas_enabled = false
    Subscription.find( :all ).each { |sub| sub.update! }
  end
end
