require 'test/unit'
require File.dirname(__FILE__) + '/../lib/democracyinaction'
require 'rubygems' #why do i need to do this for mocha to work?
require 'mocha'

module DemocracyInAction
  module TestHelper
    @@USER ||= ENV['USER']
    @@PASS ||= ENV['PASS']
    @@ORG ||= ENV['ORG']
    def connect?
      @@USER && @@PASS && @@ORG
    end
  end
  # if connect? warn "actually trying connecting to ORGKEY, might not leave things the way they started
end

class Test::Unit::TestCase
  include DemocracyInAction::TestHelper
end
