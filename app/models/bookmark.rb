class Bookmark < ActiveRecord::Base
  belongs_to :page
  belongs_to :user
  validates_uniqueness_of :page_id, :scope => :user_id, :message => 'is already bookmarked'
  
  has_finder :allowed, Proc.new{ |user|
    base_condition = { :include => :page }
      if user.superuser?
        {}
      elsif not user.is_a? AuthenticatedUser
        { :include => :page, :conditions => [ 'pages.public = ?', true ] } 
      else
        public_condition = self.__send__( :sanitize_sql_for_conditions, [ "pages.public = ?", true ] )
        not_a_page_condition = "bookmarks.page_id IS NULL"
        user_groups =  user.member_of_group_ids
        membership_condition = self.__send__( :sanitize_sql_for_conditions,["pages.group_id IN (?)", user_groups.flatten.uniq]) unless user_groups.empty?
        personal_condition =  self.__send__( :sanitize_sql_for_conditions,
              [ "pages.created_by_id = ? ", user.id ] )
# disable grants for bookmarks for now -- bookmark-page-permission relationship too complex
#              [ "pages.created_by_id = ? "+
#              "OR ("+
#                  "permissions.grantee_type = 'User' AND "+
#                  "permissions.grantee_id = ? AND "+
#                  "permissions.view = ? "+
#              ")", user.id, user.id, true ])
        { :conditions => [ public_condition, membership_condition, personal_condition, not_a_page_condition ].join( ' OR ' ), :include => [ :page ]  } 
      end
  }

  include PageUrlHelper
  def url
    read_attribute('url') || page_url(page)
  end
  
  def external?
    !(url.nil?) && url =~ /^http/

  end

end
