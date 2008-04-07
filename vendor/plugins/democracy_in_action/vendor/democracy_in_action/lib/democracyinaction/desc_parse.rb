require 'rexml/document'
require 'rexml/streamlistener'

include REXML

module DemocracyInAction
  # first, a little helper class to hold a field
  class FieldDesc
    attr_accessor :field, :type, :null, :key, :default, :extra

    # takes a Hash input
    def initialize(first)
      self.field = first['Field']
      self.type = first['Type']
      self.null = first['Null']
      self.key = first['Key']
      self.default = first['Default']
      self.extra = first['Extra']
    end
  end

  # a parser just for the table descriptions
  # call result() to get an Array of FieldDesc
  class DIA_Desc_Listener
    include StreamListener

    def initialize
      @fields = Array.new
      @key = nil
      @tmp = nil
    end

    def tag_start(name, attributes)
      case name
      when 'Field'
        @fields << FieldDesc.new(@tmp) if @tmp;
        @tmp = Hash.new
        @key = name
      when 'Type', 'Null', 'Key', 'Default', 'Extra'
        @key = name
      end
    end

    def tag_end(name)
      @key = nil
      # and a hack so the last field gets added anyway...
      @fields << FieldDesc.new(@tmp) if (name == "data")
    end

    def text(text)
      @tmp[@key] = text if @key
    end

    # returns - Array of FieldDesc
    def result()
      return @fields
    end

  end
end
