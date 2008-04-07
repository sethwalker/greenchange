module DemocracyInAction
  module Util
    ################# CONVENIENCE FUNCTIONS #####################
    
    ########  GET INFORMATION ##############
    
    # returns the number of rows in a given table
    def count(table)
      return get(table, {'count' => true, 'limit' => 1})
    end

    #  returns an array with the column descriptions of table.
    #  each array element is a FieldDesc object
    def describe(table)
      return get(table, {'desc' => true})
    end

    # return one group by key
    def getGroup(key)
      return get('groups', key)
    end

    # returns an Array of all groups
    def getGroups()
      return get('groups', nil)
    end

    # return a list of groups that match some criteria
    def getGroupsWhere(criteria)
      where = whereStr(criteria)
      puts "where: #{where}" if $DEBUG
      return get('groups', {'where' => where})
    end

    # get a list of all group names in Array of Hashes
    # each Hash is one row { 'Group_Name' => name, 'groups_KEY' => key }
    def getGroupNames()
      return get( 'groups', {'column' => 'Group_Name'} )
    end

    # get a list of all groups in a Hash 
    #  indexed by groups_KEY, value is Group_Name
    def getGroupNamesAssoc()
      names = getGroupNames()
      result = Hash.new
      names.each do |row|
        result[row['groups_KEY']] = row['Group_Name']
      end
      return result
    end

    # returns one event, indexed by key
    def getEvent(key)
      return get('event', key)
    end

    # returns all events as array
    def getEvents()
      return get('event', nil)
    end

    # returns one supporter, indexed by key
    def getSupporter(key)
      return get('supporter', key)
    end

    # returns all supporters
    def getSupporters()
      return get('supporter', nil)
    end

    # gets key(s) for supporters that match criteria ("where" -> ...)
    # returns array for one or more matches, nil on failure
    def getSupporterKey(criteria)
      return getRecordKey('supporter', criteria)
    end

    # gets key for supporter with a given email (or nil for no match)
    def getSupporterKeyByEmail(email)
      sup = getSupporterKey( {'Email' => email} )
      return sup ? sup[0] : nil
    end

    # returns group_KEYS for all groups this supporter belongs to
    def showMemberships(supporter_key)
      groups = get('supporter_groups', 
                      { 'where' => 'supporter_KEY='+supporter_key.to_s })
      return groups.map { |g| g['groups_KEY'] }
    end

    # TODO: doesn't work cuz dia is fucked.
    # can't search supporter_groups table by groups_KEY (even if the
    # data should match, and is in the db)
    def isMember(supporter_key, group_key)
      return getRecordKey('supporter_groups',
                { 'supporter_KEY' => supporter_key,
                  'groups_KEY' => group_key });
    end

    def isMemberByEmail(email, group_key)
      supporter_key = getSupporterKeyByEmail(email)
      return isMember(supporter_key, group_key)
    end

    # for no matches, returns nil
    # for one or more matches, returns an array with all matching record keys
    def getRecordKey(table, criteria)
      if (criteria != nil && criteria.class != Hash)
        raise RuntimeError, "getRecordKey needs hash criteria"
      end

      where = whereStr(criteria)
      puts "where: #{where}" if $DEBUG
      record = get(table, {'where' => where, 'column' => table+'_KEY'} )
      if (record.size > 0)
        return record.map { |r| r[table+'_KEY'] }
      else
        return nil
      end
    end
    
    ################### CHANGE INFORMATION #########################

    # This adds one event, with data from a hashtable
    def addEvent(data)
      return process('event', data)
    end

    # data - if only String, assume key 'Group_Name'
    def addGroup(data)
      if (data.class != Hash)
        data = { 'Group_Name' => data }
      end
      return process('groups', data)
    end

    # This adds all supporters as members of every group passed in.
    # * supporters - one or Array of supporter_KEYs 
    # * groups - one or Array of group_KEYs 
    # * links every supporter to every group 
    # returns array of supporter_groups record keys... 
    #
    # TODO: DIA bug - allows you to link to non-existant groups
    def addMembers(supporters, groups)
      groups = [ groups ] if (groups.class != Array)
      supporters = [ supporters ] if (supporters.class != Array)
      result = Array.new
      groups.each do |group|
        supporters.each do |support|
          result << linkSupporter(group, support)
        end
      end
      return result
    end

    # * emails - one or Array of email addresses of new supporters 
    # * groups - list of groups these new members belong to 
    # creates new members from emails, and links them to groups. 
    # returns as addMembers
    def addMembersByEmail(emails, groups)
      members = emails.map { |x| addSupporter(x) }
      return addMembers(members, groups)
    end

    # data - Hash of name/value pairs to insert on new supporter
    #         or String with email address <br>
    # returns new supporter_id
    def addSupporter(data)
      if (data.class != Hash)
        data = {'Email' => data} 
      end
      links = nil;
      if (data['link'])
        links = data['link']
        data.delete('link')
      end

      supporter_id = process("supporter", data)
      if (links)
        processLinks(supporter_id, links)
      end
      return supporter_id
    end

    # This links a supporter to another object (like group),
    #   mainly used for group membership, but theoretically more general. 
    # * supporter - one ID to link 
    # * key - one key to link supporter to (default: group_KEY) 
    # * link - type of object you link supporter to (default: groups)
    def linkSupporter(key, supporter, link = 'groups')
      link_table = 'supporter_' + link
      link_key = link + '_KEY'
      return process(link_table, { 'supporter_KEY' => supporter,
                                   link_key => key })
    end

    # * supporter_key - id of one supporter 
    # * links - Hash to link supporter to.  Hash keys is type (eg. 'groups')
    # 				Hash value is one key, or array of keys to link supporter to
    def processLinks(supporter_key, links)
      results = Array.new
      links.each do |link, keys|
        keys.each do |key|
          results << linkSupporter(key, supporter_key, link)
        end
      end
      return results
    end

    #################### REMOVE INFORMATION ####################
    
    # Deletes one element from db, as defined by table name and key
    def deleteKey(table, key)
      return delete(table, {'key' => key})
    end

    #################### INTERNAL HELPER FUNCTIONS ######################
    protected

    # make a where clause from a hash table.
    # only supports <key>=<value> joined by AND, 
    # if you want a more complex one, build it yourself.
    # (just make sure to omit any ()'s in your statement)
    def whereStr(criteria)
      where = Array.new
      criteria.each do |key, value|
        where << key + '="' + value.to_s + '"'
      end
      return where.join(' AND ')
    end
  end
end
