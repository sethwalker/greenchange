$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

%w(net/http).each { |f| require f }

require 'democracyinaction/version'
require 'democracyinaction/util'
require 'democracyinaction/config_rexml'
require 'democracyinaction/xml_parse'
require 'democracyinaction/desc_parse'
require 'democracyinaction/api'

#legacy
class DIA_API
  def DIA_API.create(options = {})
    warn "#{caller[1]}:Warning: DIA_API.create is deprecated.  Use the gem instead"
    type = options.delete('type')
    case type
      when "default", "DIA_Simple", nil
        return DIA_API_Simple.new(options)
      else
        raise(RuntimeError, "unsupported type of DIA_API - #{type}")
    end
  end
end

class DIA_API_Simple < DemocracyInAction::API
end
