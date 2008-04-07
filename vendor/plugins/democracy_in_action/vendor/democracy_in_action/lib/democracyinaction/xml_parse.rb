require 'rexml/streamlistener'
#require 'rexml/document'

include REXML

# this parses out items of name/value pairs well, for example in
# get...() code.  it doesn't work on descibe() results at all :(
#
# it has three accessors when filled in:
#   items - Array of Hashes, each Hash is one database row
#   count - the number of database rows that would be returned
#   type - the data type name in the xml (eg. 'event', 'groups', 'supporter')
module DemocracyInAction
  class DIA_Get_Listener
    include StreamListener

    attr_reader :items, :count, :type

    def initialize()
      @items = Array.new
      @in_item = false
      @key = nil
      # state variables to pick up the count and the datatype
      @count, @in_count = 0, false
      @type, @next_type = nil, false
      @tmp = Hash.new
    end

    def tag_start(name, attributes)
      if (@in_item)
        @key = name
      elsif (@next_type)
        @type = name
        @next_type = false
      elsif (name == "item")
        # puts "entering item"
        @in_item = true
        @tmp = Hash.new
      elsif (name == "count")
        @in_count = true
      elsif (name == "data")
        # the type is the next tag after <data>
        @next_type = true
      end
    end

    def tag_end(name)
      if (name == "item")
        # puts "storing tmp - #{@tmp.inspect}"
        @items << @tmp
        @in_item = false;
      elsif (@in_item)
        @key = nil
      elsif (name == "count")
        @in_count = false
      end
    end

    # store any text we find between start and end tags
    def text(text)
      if (@in_item && @key)
        # puts "Storing #{@key} = #{text}"
        @tmp[@key] = text
      elsif (@in_count)
        @count = text.to_i
      end
    end

  end
end

=begin
listener = DIAListener.new
parser = Parsers::StreamParser.new(File.new(NAME), listener)
parser.parse
puts "Result-----"
puts listener.parsed.each { |x| puts x.inspect }
=end
