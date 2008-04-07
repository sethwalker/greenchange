module DemocracyInAction
  class API
    include DemocracyInAction::Util

    @@DEFAULT_URLS = { 'get' => 'http://api.democracyinaction.org/dia/api/get.jsp',
                       'process' => 'http://api.democracyinaction.org/dia/api/process.jsp',
                       'delete' => 'http://api.democracyinaction.org/dia/api/delete.jsp'
    }

    attr_reader :user, :password, :orgkey
    attr_reader :urls

    # options...  (default: above urls, no auth)
    # authCodes => [name, password, orgKey]
    # urls => { 'get' => get_url, 'process'..., 'delete'..., 'unsub'... }
    def initialize(options = {})
      @cookies = Array.new
      @urls = @@DEFAULT_URLS.clone
      return unless options

      # accept authCodes option as Array
      if (options['authCodes'])
        if (options['authCodes'].class != Array)
          raise(StandardError, "authCodes must be Array [name, password, orgkey]")
        end
        @user, @password, @orgKey = options['authCodes']
      end

      # accept urls option as Hash
      if (options['urls'])
        # make sure it's a Hash argument
        new_urls = options['urls']
        if (new_urls.class != Hash)
          raise(StandardError, "urls option must be Hash")
        end

        # make sure the keys are all valid and save them
        new_urls.each do |key, value|
          if (! @@DEFAULT_URLS[key])
            raise(StandardError, "Bad url option - #{key}")
          end
          @urls[key] = value
        end
      end
    end

    # There are a lot of functions that take the same variable names..
    # Here is a description of common arguments
    #   table - SQL table name (String)
    #   options - SQL options (Hash) (ex. {"limit" => 4} )
    #   		(sometimes it takes one value with assumed name,
    #   		 read individual functions for more info)
    #   data - SQL column names/values to insert (Hash)
    #           (ex.  {'key' => key, 'First_Name' => name } )
    #   criteria - SQL column names/values for WHERE clause (HASH)
    #   	    (ex. {'Email' => email} mean "WHERE Email == email" )
    # More details on individual functions
    #
    # API notes:  there are some bug(?) in the DIA side...
    #   1. only characters accepted in where clause [0-9a-zA-Z_ .'"<>!=%+&@-]
    #      therefore, don't put others (like ,) in names or you can't search
    #   2. you cannot search the supporter_groups links by groups_KEY
    #   3. you can link supporters to invalid group keys (and visa versa)
    #   4. when you delete a group, the links in supporter_groups are not erased
    #      (but if you delete a suporter, they are)
    #      i think this discrepancy has to do with (2)


    # gets an "XML" document with the table info
    # if options['count'], returns integer (number of matches)
    # if options['desc'], returns TableDesc instance
    # else, returns Array of Hashes, each Hash is one database row 
    #
    # options - Hash keys: 'key', 'column', 'order', 'limit', 'where', 'desc' 
    #
    #           String:  same as { 'key' => String }
    def get(table, options = nil)
      options = processOptions(table, options)

      # if multiple keys (array), join keys with comma
      # (only for get command)
      if options['key'] && (options['key'].class == Array) then
        value = options['key'].join(', ')
        options['key'] = value	
      end

      # make a HTTP post
      res = sendRequest(@urls['get'], options)

      # interpret the results...
      if (options['desc'])
        # the description is a different format and needs a different parser
        listener = DIA_Desc_Listener.new
        parser = Parsers::StreamParser.new(res, listener)
        parser.parse
        return listener.result
      else
        # everything else has the same db format
        listener = DIA_Get_Listener.new
        parser = Parsers::StreamParser.new(res, listener)
        parser.parse
        if (options['count'])
          return listener.count
        else
          return listener.items
        end
      end
    end

    # options - Hash keys: 'key', 'debug' <br>
    #
    #           String: same as { 'key' => String }
    # TODO: document link option???
    def process(table, options = nil)
      options = processOptions(table, options)
      # special code to handle multiple links...
      if options['link'] then
        links = linkHashToQueryStringArray(options['link'])
        options['link'] = links
      end

      res = sendRequest(@urls['process'], options)

      # i think the result is always a number (id) surrounded
      # by too much whitespace
      return res.strip
    end

    # delete code
    # returns true if it works, false otherwise
    # takes an hash like {'key' => key}
    # haven't found other options to work
    #
    # criteria - any value column/values pair on the table (as Hash) 
    # 
    #            if String, same as { 'key' => String }
    def delete(table, criteria)
      options = processOptions(table, criteria)
      options.delete('simple')
      options['xml'] = true

      res = sendRequest(@urls['delete'], criteria)
    
      # if it contains '<success', it worked, otherwise a failure
      if res.include?('<success')
        return true
      else
        puts res if $DEBUG
        return false
      end
    end
    ###################### INTERNAL CODE ###################

    protected
    # copied from private function in Net::HTTP
    def urlencode(str)
      str.gsub(/[^a-zA-Z0-9_\.\-]/n) {|s| sprintf('%%%02x', s[0]) }
    end

    # this takes the table name and (possibly nil) options
    # and returns one hash with them all, handling key processing
    def processOptions(table, options)
      # handle no options as well as String representing the key value
      if (! options) then 
        options = { }
      elsif (options.class != Hash)
        options = { 'key' => options }
      end

      # default options
      options['table'] = table
      options['simple'] = true

      return options
    end

    # links are sent in a Hash.
    # every key is a table name
    # value is either key in that table, or Array of keys in that table
    # return an Array of values that can be added to a query string
    def linkHashToQueryStringArray(links)
      if !links || !links.is_a?(Hash) then
        raise(StandardError,"bad links value")
      end

      strings = Array.new
      links.each do |table, key|
        if key.class == Array then
          key.each { |k| strings << table+'|'+k.to_s }
        else
          strings << table+'|'+key.to_s
        end
      end
      return strings
    end

    # helper function for sendRequest to handle multiple entries
    # with same key name
    def buildBody(options)
      # in order to handle multiple links, keys...
      # if an option has an Array as value, append each array element
      # as "<key>=<array element>&"
      tmp = Array.new
      options.each do |k,v| 
        if v.class == Array then
          v.each { |vv| tmp << "#{urlencode(k.to_s)}=#{urlencode(vv.to_s)}" }
        else
          tmp << "#{urlencode(k.to_s)}=#{urlencode(v.to_s)}"
        end
      end
      body = tmp.join('&')
    end

    def self.disabled?
      false
    end

    # specialized code to handle multiple form entries with same key name
    # also does some error handling
    def sendRequest(my_url, options, redirects = 5)
      return '' if API.disabled?
            
      # make a HTTP post and set the cookies
      url = URI.parse(my_url)
      req = Net::HTTP::Post.new(url.path)
      @cookies.each { |c| req.add_field('Cookie', c) }
      
      # import authentication information
      options['organization_KEY'] = @orgKey if (@orgKey)
      if (@user && @password)
        options['user'] = @user
        options['password'] = @password
      end

      # format request and get result
      req.body = buildBody(options)
      puts req.body if $DEBUG
      req.set_content_type('application/x-www-form-urlencoded')
      res = Net::HTTP.new(url.host, url.port).start { |http| http.request(req) }

      # error handling
      # TODO: handle cookies
      # TODO: catch error responses... on lines 3 and 4
      #  you see java.lang.Exception if there was an error
      case res
        when Net::HTTPSuccess
          # Good, now grab any cookies we can
          cookies = res.get_fields('Set-Cookie')
          if cookies
            cookies.each { |c| @cookies.push(c.split(';')[0]) }
          end
        when Net::HTTPRedirection
          # try to follow redirects, up to a maximum
          raise(RuntimeError, "Too many redirects!") if (redirects <= 0)
          loc = res['Location']
          puts "Redirect to #{loc}" if $DEBUG
          return sendRequest(loc, options, redirects - 1)
        else
          # or do something more interesting???
          res.error!
      end
    
      return res.body
    end

  end
end
