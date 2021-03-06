module NetworkContentHelper

  def featured_pages( source, qty = 1 )
    # TODO: network content sorting
    if source && source.is_a?(Issue)
      [source.featured_pages.find(:first, :order => "rand()")].compact
    elsif source
      return [] unless source.respond_to?(:pages) && source.pages.any?
      [ Page.send(*context_finder(source)).find(:first, :order => "updated_at DESC") ].compact
    else
      find_random Page, qty
    end
  end

  def featured_users( source, qty = 6 )
    # TODO: network content sorting
    if source
      return [] unless source.respond_to?(:users) && source.users.any?
      source.users.enabled.find(:all, :limit => qty, :order => "updated_at DESC") 
    else
      User.enabled.featured.find(:all, :limit => qty, :order => "updated_at DESC") 
      #find_random User, qty
    end
  end

  def featured_groups( source=nil, qty = 6 )
    # TODO: network content sorting
    if source
      return [] unless source.respond_to?(:groups) && source.groups.any?
      source.groups.find(:all, :limit => qty, :order => "updated_at DESC")
    else
      Group.featured.find(:all, :limit => qty, :order => "updated_at DESC")
      #find_random Group, qty 
    end
  end

  def find_random( klass, qty )
    #TODO find a way to get rid of this special-case sql and use the named_scope
    if klass == User
      ids = klass.connection.select_all("Select id from #{klass.name.tableize} where " + klass.__send__( :sanitize_sql_for_conditions, [ "enabled= ? and activated_at IS NOT NULL", true ]))
    else
      ids = klass.connection.select_all("Select id from #{klass.name.tableize}")
    end

    random_ids = []
    qty.times do
      next if ids.empty?
      random_index = rand( ids.size )
      random_ids << ids.delete_at( random_index )["id"].to_i
    end
    
    klass.find(random_ids)
  end
end
