module NetworkContentHelper

  def featured_pages( source )
    # TODO: network content sorting
    return [] unless source.respond_to?(:pages) && source.pages.any?
    [ source.pages.find(:first, :order => "updated_at DESC") ].compact
  end

  def featured_users( source )
    # TODO: network content sorting
    return [] unless source.respond_to?(:users) && source.users.any?
    source.users.find(:all, :limit => 6, :order => "updated_at DESC") 
  end

  def featured_groups( source )
    # TODO: network content sorting
    return [] unless source.respond_to?(:groups) && source.groups.any?
    source.groups.find(:all, :limit => 6, :order => "updated_at DESC")
  end
end
