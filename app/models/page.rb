
# notes
# all the relationship between a page and its groups is stored in the group_participations
# table. however, we denormalize some of it: group_name and group_id are used to store
# the info for the 'primary group'. what does this mean? the primary group is what is 
# show when listing pages and it is the default group when linking from a wiki. 
# 

class Page < ActiveRecord::Base
  acts_as_modified

  has_many :permissions, :as => 'resource'

  #allowed_collectings = Collecting.allowed(user,perm).find( :all, :conditions => [ 'collectable_type = ?', self.name] )
  has_finder :allowed, 
    Proc.new { |user, perm| 
      unless [:view, :edit, :participate, :admin].include? perm
        {} 
      else
        public_condition = (perm != :admin) ? self.__send__(:sanitize_sql_for_conditions, ["pages.public = ?", true]) : nil 
        user_groups = []
        user_groups << user.contributes_to_group_ids  if perm == :edit 
        user_groups << user.member_of_group_ids       if perm == :view or perm == :participate
        user_groups << user.admin_of_group_ids        if perm == :admin

        membership_condition = self.__send__(:sanitize_sql_for_conditions, ["pages.group_id IN (?)", user_groups.flatten.uniq]) unless user_groups.empty?
      { :include => :permissions,
        :conditions => 
        [
          conditions = [
            public_condition, 
            membership_condition,
            "pages.created_by_id = ? "+
            "OR ("+
                "permissions.grantee_type = 'User' AND "+
                "permissions.grantee_id = ? AND " +
                "permissions.#{perm} = ? "+
            ")"
          ].compact.join(' OR '),
          user.id, user.id, true
        ],
      }
      end
    }

  has_finder :permitted_for, 
    Proc.new { |user, perm| 
      { :include => :permissions, :conditions => 
        [
          "("+
              "permissions.grantee_type = 'User' AND "+
              "permissions.grantee_id = ? AND " +
              "permissions.#{perm} = ? "+
          ")",
          user.id, true
        ],
      }
    }

  has_finder :by_group, lambda {|*groups|
      groups.any? ? { :conditions => [ 'group_id in (?)', groups ] } : {}
    }
  has_finder :by_issue, {} #lambda {|*issues| }
  has_finder :by_person, {} #lambda {|*people| }
=begin
  def Page.allowed(user, perm=:view)
    # unknown actions allow nothing
    return [] if not [:view, :edit, :participate, :admin].include? perm

    by_permission   = permitted_for(user, perm)
    by_creation     = created_by(user)

    user_groups = []

    if perm == :admin
      by_public = []
      user_groups << user.admin_of_group_ids 
    else
      by_public = self.public
    end

    user_groups << user.contributes_to_group_ids  if perm == :edit 
    user_groups << user.member_of_group_ids       if perm == :view or perm == :participate

    by_memberships = find(:all, :conditions => ["pages.group_id IN(?) ", user_groups.uniq!])

    # all together now
    by_public +
      by_creation +
      by_permission +
      by_memberships
  end
=end

  has_finder :in_network,
    lambda {|user| {:include => [:group_participations, :user_participations], :conditions => ["user_participations.user_id = ? OR group_participations.group_id IN (?)", user.id, user.all_group_ids]}}


  has_finder :changed, {:conditions => "pages.updated_at > pages.created_at"}

  #note, don't use finders that depend on user_participations for a specific users starred pages, use user.pages_starred, etc instead
  has_finder :starred?, 
    Proc.new {|starred| 
      starred ? {:include => :user_participations, :conditions => ["user_participations.star = ?", true]} : {}
    }

  has_finder :pending?, 
    Proc.new {|pending| pending ? {:conditions => ["pages.resolved = ?", false]} : {}}

  has_finder :created_in_month, 
    Proc.new {|month| 
      month ? {:conditions => ["#{Page.sql_month('pages.created_at')} = ?", month]} : {}
    }

  has_finder :created_in_year,  
    Proc.new {|year| 
      year ? {:conditions => ["#{Page.sql_year('pages.created_at')} = ?", year]} : {}
    }

  has_finder :created_by, 
    Proc.new {|user| user ? {:conditions => ["created_by_id = ?", user]} : {}}

  has_finder :viewable_in_group,
    Proc.new {|group, user| 
      group = Group.find(group) if group && !group.is_a?(Group)
      user  = User.find(user) if user && !user.is_a?(User)
      if group
        if user 
#          {:include => :collections, :conditions => ["collections.id IN (?)", group.collections_viewable_by_user(user)]}
          $stderr.puts('hey') if RAILS_ENV='test'
        else
          {:include => :collection, :conditions => ["collections.id IN (?)", group.collection_ids]}
        end
      else
        {}
      end
    }

  has_finder :page_type, 
    lambda {|*page_types| 
      page_types = [:audio,:video,:image,:asset] if page_types==[:media]
      page_types = page_types.flatten.map do |t| 
        #"class_group" used to do this
        t = 'task_list'     if t.to_s == 'task'
        t = 'text_doc'      if t.to_s == 'wiki'
        t = 'ranked_vote'   if t.to_s == 'vote'
        t = 'rate_many'     if t.to_s == 'poll'

        #can pass constants, strings, symbols, strings and symbols don't have to be prefixed with tool
        #e.g. Page.page_type(Tool::Asset), Page.page_type(:asset), Page.page_type('asset'), Page.page_type('Tool::Asset'), Page.page_type(:image, :video), Page.page_type([:image, :video])
        klass = if t.is_a?(Class) && t < Page
                  t
                elsif t =~ /^Tool::/ && t.constantize < Page
                  t.constantize 
                else
                  Tool.const_get(t.to_s.classify) if Tool.const_get(t.to_s.classify) < Page
                end
        raise 'invalid page type' unless klass

        [klass.to_s] + klass.subclasses.map {|c| c.to_s}
      end.compact.flatten.uniq
      raise 'invalid page type(s)' unless page_types.any?
      page_types.any? ? {:conditions => ["pages.type IN (?)", page_types]} : {}
    }

  has_finder :public, {:conditions => ["pages.public = ?", true]}

  has_finder :tagged, 
    lambda {|*tags| 
      Tag
      tags.any? ? {:include => :tags, :conditions => ["tags.name IN (?)", *tags]} : {}
    }

  has_finder :text, 
    Proc.new {|text| text ? {:conditions => ["pages.title LIKE ?", "%#{text}%"]} : {}}
  
  #TODO: move to general purpose
  def self.sql_month(expr)
    case connection.adapter_name
    when "SQLite"
      "CAST(STRFTIME('%m', #{expr}) as 'INTEGER')"
    when "MySQL"
      "MONTH(#{expr})"
    else
      raise "#{connection.adapter_name} is not supported"
    end
  end

  def self.sql_year(expr)
    case connection.adapter_name
    when "SQLite"
      "CAST(STRFTIME('%Y', #{expr}) as 'INTEGER')"
    when "MySQL"
      "YEAR(#{expr})"
    end
  end

  extend PathFinder::FindByPath

  #######################################################################
  ## PAGE NAMING
  
  validates_format_of  :name, :with => /^$|^[a-z0-9]+([-_]*[a-z0-9]+){1,39}$/

  def validate
    if name_modified? and name_taken?
      errors.add 'name', 'is already taken'
    end
  end

  def name_url
    name.any? ? name : friendly_url
  end
  
  def friendly_url
    s = title.nameize
    s = s[0..40].sub(/-([^-])*$/,'') if s.length > 42     # limit name length, and remove any half-cut trailing word
    "#{s}+#{id}"
  end

  def to_param
    "#{id}+#{title.nameize}"
  end

  # returns true if self's unique page name is already in use.
  # what pages are in the namespace? all pages connected to all
  # groups connected to this page (include the group's committees too).
  def name_taken?
    return false unless self.name.any?
    p = Page.find(:first,
      :conditions => ['pages.name = ? and group_participations.group_id IN (?)', self.name, self.namespace_group_ids],
      :include => :group_participations
    )
    return false if p.nil?
    return self != p
  end

  #######################################################################
  ## RELATIONSHIP TO PAGE DATA
  
  belongs_to :data, :polymorphic => true
  has_one :discussion, :dependent => :destroy
  has_many :assets, :dependent => :destroy
      
  validates_presence_of :title
  validates_associated :data

  def unresolve
    resolve(false)
  end
  def resolve(value=true)
    user_participations.each do |up|
      up.resolved = value
      up.save
    end
    self.resolved=value
    save
  end  

  def build_post(post,user)
    # this looks like overkill, but it seems to be needed
    # in order to build the post in memory and have it saved when
    # (possibly new) pages is saved
    self.discussion ||= Discussion.new
    self.discussion.page = self
    if post.instance_of? String
      post = Post.new(:body => post)
    end
    self.discussion.posts << post
    post.discussion = self.discussion
    post.user = user
    return post
  end
  
  ## update ASSET permissions
  after_save :update_access
  def update_access
    assets.each { |asset| asset.update_access }
  end
  
  #######################################################################
  ## RELATIONSHIP TO USERS

  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
  belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
  has_many :user_participations, :dependent => :destroy
  has_many :users, :through => :user_participations do
    def with_access
      find(:all, :conditions => 'access IS NOT NULL')
    end
    def participated
      find(:all, :conditions => 'changed_at IS NOT NULL')
    end
  end

  # like users.with_access, but uses already included data
  def users_with_access
    user_participations.collect{|part| part.user if part.access }.compact
  end
  
  # like users.participated, but uses already included data
  def contributors
    user_participations.collect{|part| part.user if part.changed_at }.compact
  end
  
  # like user_participations.find_by_user_id, but uses already included data
  def participation_for_user(user) 
    user_participations.detect{|p| p.user_id==user.id }
  end

  # used for ferret index
  def user_ids
    user_participations.collect{|upart|upart.user_id}
  end

  before_create :set_user
  def set_user
    if User.current or self.created_by
      self.created_by ||= User.current
      self.created_by_login = self.created_by.login
      self.updated_by       = self.created_by
      self.updated_by_login = self.created_by.login
    end
    true
  end

  has_many :bookmarks

  #######################################################################
  ## RELATIONSHIP TO GROUPS
  
  has_many :group_participations, :dependent => :destroy
  has_many :groups, :through => :group_participations
  belongs_to :group # the main group
  
  has_many :namespace_groups, :class_name => 'Group', :finder_sql => 'SELECT groups.* FROM groups WHERE groups.id IN (#{namespace_group_ids_sql})'
  
  # When getting a list of ids of groups for this page,
  # we use group_participations. This way, we will have
  # current data even if a group is added and the page
  # has not yet been saved.
  # used extensively, and by ferret.
  def group_ids
    group_participations.collect{|gpart|gpart.group_id}
  end
  
  # returns an array of group ids that compose this page's namespace
  # includes direct groups and all the relatives of the direct groups.
  def namespace_group_ids
    Group.namespace_ids(group_ids)
  end
  def namespace_group_ids_sql
    namespace_group_ids.any? ? namespace_group_ids.join(',') : 'NULL'
  end

  # takes an array of group ids, return all the matching group participations
  # this is called a lot, since it is used to determine permission for the page
  def participation_for_groups(group_ids) 
    group_participations.collect do |gpart|
      gpart if group_ids.include? gpart.group_id
    end.compact
  end
  def participation_for_group(group)
    group_participations.detect{|gpart| gpart.group_id == group.id}
  end

  #######################################################################
  ## RELATIONSHIP TO ENTITIES
    
  # add a group or user participation to this page
  def add(entity, attributes={})
    attributes[:access] = ACCESS[attributes[:access]] if attributes[:access]
    if entity.is_a? Enumerable
      entity.each do |e|
        e.add_page(self,attributes)
      end
    else
      entity.add_page(self,attributes)
    end
    self
  end
      
  # remove a group or user participation from this page
  def remove(entity)
    if entity.is_a? Enumerable
      entity.each do |e|
        e.remove_page(self)
      end
    else
      entity.remove_page(self)
    end
  end

  
  #######################################################################
  ## SUPPORT FOR PAGE SUBCLASSING

  # to be set by subclasses (ie tools)
  class_attribute :controller, :model, :icon,
    :class_description, :class_display_name

  def self.icon_path
    "/images/pages/#{self.icon}"
  end

  def icon_path
    self.class.icon_path
  end

  def self.big_icon_path
    "/images/pages/big/#{self.icon}"
  end

  def big_icon_path
    self.class.big_icon_path
  end

  # lets us convert from a url pretty name to the actual class.
  def self.display_name_to_class(display_name)
    dn = display_name.nameize
    Page.subclasses.detect{|t|t.class_display_name.nameize == dn if t.class_display_name}
  end 

  #######################################################################
  ## DENORMALIZATION

  before_save :denormalize
  def denormalize
    # denormalize hack follows:
    if changed? :groups 
      # we use group_participations because self.groups might not
      # reflect current data if unsaved.
      group = (group_participations.first.group if group_participations.any?)
      self.group_name = (group.name if group)
      self.group_id = (group.id if group)
    end
    if changed? :updated_by
      self.updated_by_login = updated_by.login
    end
    true
  end
  
  # used to mark stuff that has been changed.
  # so that we know we need to update other stuff when saving.
  def changed(what)
    @changed ||= {}
    @changed[what] = true
  end
  def changed?(what)
    @changed ||= {}
    @changed[what]
  end

  #######################################################################
  ## MISC. HELPERS

  # tmp in-memory storage used by views
  def flag
    @flags ||= {}
  end

  def self.make(function,options={})
    PageStork.send(function, options)
  end

  #######################################
  ## USER behavior
  def starred_by?( user )
    !user_participations.find( :first, "user_id = ? and starred IS NOT ?", user, nil ).nil?
  end

  # does this page allow attachments?
  def accepts_attachments?
    [ Event, Wiki, Message, Discussion, Blog ].any? { |klass| self.data && self.data.is_a?( klass ) }
  end

  # check if user has permission to perform the action on this page
  def allows?(user, action)
    unless [:view, :edit, :participate, :admin].include? action
      action = Permission.alias_for( action )
    end
    user.superuser? ||

    # user is page owner
    ( self.created_by == user ) ||

    # explicit permissions grant
    ( action and permissions.find(:first,
      :conditions => [
        "grantee_type = 'User' AND "+
        "grantee_id = ? AND "+
        "#{action} = ?",
        user.id, true
      ]
    )) ||

    # abide by group policy if the page belongs to a group
    #( !self.group.nil? and self.group.role_for(user).allows?(action, self) )
    ( !self.group_participations.empty? and self.group_participations.any? { |gpart|
        gpart.group.role_for(user).allows?(action, self ) } )

  end
end
