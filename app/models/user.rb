#require 'crabgrass/active_record/collector'
class User < ActiveRecord::Base

  include AuthenticatedUser
  include SocialUser
  include Crabgrass::ActiveRecord::Collector

  validates_acceptance_of :terms_of_service, :message => 'must be agreed to before you can sign up'
  validates_presence_of :login
  validates_uniqueness_of :login
  validates_format_of :login, :with => /^[a-z0-9]+([-\+_]*[a-z0-9]+){1,49}$/, :message => 'may only contain letters, numbers, underscores, and hyphens'
  validates_length_of :login, :in => 3..50, :message => 'must be at least 3 and no more than 50 characters'

  acts_as_modified

  #validate                 :validate_profiles
  validates_presence_of    :email
  validates_as_email       :email
  #validates_format_of      :email, :with => /(^([^@\s]+)@((?:[-_a-z0-9]+\.)+[a-z]{2,})$)|(^$)/i
  #validates_length_of      :email,    :within => 6..100

  has_many :gives_permissions,  :as => 'grantor', :class_name => 'Permission'
  has_many :given_permissions,  :as => 'grantee', :class_name => 'Permission'
  has_many :preferences, :dependent => :destroy 
  has_many :languages, :class_name => 'Profile::Language'

  def preferences=(settings)
    if settings.is_a? Hash
      settings.each do |key, value|
        pref = preferences.find_by_name(key.to_s) || preferences.build( :name => key.to_s)
        pref.value = value 
      end
    end
  end

  def preference_for(key)
    preferences.detect { |p| p.name == key.to_s }.try(:value)
  end

  has_finder :by_issue, lambda {|*issues|
    issues.any? ? { :include => :issue_identifications, :conditions => [ "issue_identifications.issue_id in (?)", issues ] } : {}
  }
  has_finder :enabled, :conditions => [ "users.enabled = ? and users.activated_at IS NOT NULL", true ]
 

  #has_many :memberships
  def admin_of_group_ids
    memberships.find(:all, :conditions => ["role = 'administrator'"]).map(&:group_id).uniq
  end

  def contributes_to_group_ids
    memberships.find(:all,:conditions => [
      "role = 'contributor' OR role = 'administrator'"
    ]).map(&:group_id).uniq
  end

  def member_of_group_ids
    memberships.map(&:group_id)
  end

  def has_permission_to(act, on_resource)
    perm = given_permissions.find(:all,
      :conditions => [
        "#{act} = ? AND "+
        "resource_type = '#{on_resource.class}' AND "+
        "resource_id = ? ",
        true, on_resource.id
      ]
    )
    return perm.length > 0
  end

  #########################################################    
  # my identity

  has_many :issue_identifications, :as => :issue_identifying
  has_many :issues, :through => :issue_identifications, :order =>'issues.name ASC'
  def issue_ids=(issue_ids)
    issue_identifications.each do |issue_identification|
      issue_identification.destroy unless issue_ids.include?(issue_identification.issue_id)
    end
    issue_ids.each do |issue_id|
      self.issue_identifications.create(:issue_id => issue_id) unless issue_identifications.any? {|issue_identification| issue_identification.issue_id == issue_id}
    end
  end

  def language_keys=(language_keys)
    languages.each do |language|
      language.destroy unless language_keys.include?(language.language)
    end
    language_keys.each do |key|
      self.languages.create(:language => key) unless languages.any? {|language| language.language == key}
    end
  end

  def language_keys
    languages.map(&:language)
  end

  has_collections :private, :social, :public, :unrestricted

  #TODO this make this reflect real policies
  def restricted_collection_ids(perm=:view)
    if perm == :view 
      collection_ids = []
      collection_ids << private_collection.id if private_collection
      collection_ids << social_collection.id if social_collection
      collection_ids +
        (
        ( ( self.contacts.inject([]){ |collection_ids, c| collection_ids << c.social_collection.id if c.social_collection })  || [] )  +
        (( self.groups.inject([]){ |collection_ids, g| collection_ids << g.member_collection.id if g.member_collection } ) || [] ) 
        )
    else
      self.collections.map(&:id)
      #User.collections.inject{ |name, accessor| send(accessor).id }
    end
  end

  has_many :bookmarks
  has_many :bookmarked_pages, :through => :bookmarks, :source => :page
  def bookmarked?(page)
    bookmarked_pages.detect {|p| p == page}
  end
  def bookmark!(page)
    bookmarked_pages << page
  end

  acts_as_fleximage do
    image_directory 'public/images/uploaded/icons/people' 
    require_image false
    preprocess_image { |image| image.resize Crabgrass::Config.image_sizes[:large], :crop => true }
  end
  #has_many :profiles, :as => 'entity', :dependent => :destroy#, :extend => Profile::Methods
  has_one :public_profile, :as => 'entity', :dependent => :destroy, :class_name => 'Profile', :conditions => ['stranger = ?', true ]
  has_one :private_profile, :as => 'entity', :dependent => :destroy, :class_name => 'Profile', :conditions => [ 'friend = ?', true ]

  validates_format_of :login, :with => /^[a-z0-9]+([-_\.]?[a-z0-9]+){1,17}$/
  before_validation :clean_names
  
  def clean_names
    write_attribute(:login, (read_attribute(:login)||'').downcase)
    
    t_name = read_attribute(:display_name)
    if t_name
      write_attribute(:display_name, t_name.gsub(/[&<>]/,''))
    end
  end

  after_save :update_name
  def update_name
    if login_modified?
      Page.connection.execute "UPDATE pages SET `updated_by_login` = '#{self.login}' WHERE pages.updated_by_id = #{self.id}"
      Page.connection.execute "UPDATE pages SET `created_by_login` = '#{self.login}' WHERE pages.created_by_id = #{self.id}"
    end
  end

  
  # the user's custom display name, could be anything.
  def display_name
    if self.private_profile
      "#{self.private_profile.first_name} #{self.private_profile.last_name}"
    else
      self.display_name? ? read_attribute( :display_name ) : login
    end
  end
  
  # the user's handle, in same namespace as group name,
  # must be url safe.
  def name; login; end
  
  # displays both display_name and name
  def both_names
    if read_attribute('display_name').any? and read_attribute('display_name') != name
      '%s (%s)' % [display_name,name]
    else
      name
    end
  end

  def cut_name
    name[0..20]
  end
    
  def to_param
    return login
  end

  def banner_style
    @style ||= Style.new(:color => "#E2F0C0", :background_color => "#6E901B")
  end
    
  def online?
    last_seen_at > 10.minutes.ago if last_seen_at
  end

  def time_zone
    read_attribute(:time_zone) || DEFAULT_TZ
  end

  ## validations
  def validate_profiles
    if self.profiles.empty?
      self.errors.add :profiles, "User must have at least a private profile"
    end

  end

  # returns the profile appropriate to the viewer's relationship to the user
  def profile_for( person )
    if person.is_a? AuthenticatedUser
      self.private_profile ||= build_private_profile
      return private_profile if person == self or contacts.include? person #find :first, :conditions => ['contact_id = ?', person ]
    end
    self.public_profile ||= build_public_profile
  end

  # TODO: remove this transitional hack
  def profiles
    items = [ public_profile, private_profile ].compact
    class << items
      def build( *args )
        Profile.new( { :entity => user }.merge(args.extract_options!) )
      end
      attr_accessor :user
    end
    items.user = self
    items
  end

  has_many :messages_sent, :class_name => 'Message', :foreign_key => 'sender_id'
  has_many :messages_received, :class_name => 'Message', :foreign_key => 'recipient_id'
  has_many :invitations_received, :class_name => 'Invitation', :foreign_key => 'recipient_id', :conditions => "state = 'pending'"
  #has_many :messages_received, :through => :participations, :source => 'page', :conditions => ["type = ?", 'Tool::Message' ]

  def unread_messages
    pages_unread
  end

  def inbox_items
    membership_invitations + invitations_received + contact_requests_received.pending + messages_received + membership_requests_received_and_pending
  end

  def pending_items
    pages_pending
  end

  def allows?( user, action, resource = nil )
    user.superuser? ||
    action == :view ||
    user == self
    
  end

  has_many :events, :foreign_key => 'host_id'
  has_many :rsvps
  has_many :attending, :through => :rsvps, :source => :events

  def contact_for( user )
    contact_relationships.find :first, :conditions => ["contact_id = ?", user]
  end
end
