class User < ActiveRecord::Base

  include AuthenticatedUser
  include CrabgrassDispatcher::Validations
  include SocialUser

  validates_handle :login
  acts_as_modified

  validate                 :validate_profiles
  validates_presence_of    :email
  validates_format_of      :email, :with => /(^([^@\s]+)@((?:[-_a-z0-9]+\.)+[a-z]{2,})$)|(^$)/i
  validates_length_of      :email,    :within => 6..100

  #########################################################    
  # my identity

  has_many :issue_identifications, :as => :issue_identifying
  has_many :issues, :through => :issue_identifications
  def issue_ids=(issue_ids)
    issue_identifications.each do |issue_identification|
      issue_identification.destroy unless issue_ids.include?(issue_identification.issue_id)
    end
    issue_ids.each do |issue_id|
      self.issue_identifications.create(:issue_id => issue_id) unless issue_identifications.any? {|issue_identification| issue_identification.issue_id == issue_id}
    end
  end

  has_many :bookmarks
  has_many :bookmarked_pages, :through => :bookmarks, :source => :page

  belongs_to :avatar
  has_many :profiles, :as => 'entity', :dependent => :destroy, :extend => Profile::Methods

  # this is a hack to get 'has_many :profiles' to polymorph
  # on User instead of AuthenticatedUser
  #def self.base_class; User; end
  
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

  after_destroy :kill_avatar
  def kill_avatar
    avatar.destroy if avatar
  end
  
  # the user's custom display name, could be anything.
  def display_name
    read_attribute('display_name').any? ? read_attribute('display_name') : login
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

    
end
