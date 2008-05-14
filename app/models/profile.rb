=begin

A person or group profile

Every person or group can have many profiles, each with different permissions
and for different languages. A given user will only see one of these profiles,
the one that matches their language and relationship to the user/group.

Order of profile presidence (user sees the first one that matches):
 (1) foe
 (2) friend   } the 'private' profile
 (3) peer     \  might see 'private' profile
 (4) fof      /  or might be see 'public' profile
 (5) stranger } the 'public' profile

=end

class Profile < ActiveRecord::Base
  
  after_save :save_public_version

  ### relationship to user or group #########################################
  
  belongs_to :entity, :polymorphic => true
  def user; entity; end
  def group; entity; end
    
  validate :validate_user_info
  
  def validate_user_info
    return unless (self.entity.class.name =~ /User/) and self.private?
    validate_user_name
  end

  def validate_user_name
    errors.add :first_name, "First name cannot be blank" if self.first_name.blank?
    errors.add :last_name, "Last name cannot be blank" if self.last_name.blank?
  end

  ### basic info ###########################################################

  def full_name
    [name_prefix, first_name, middle_name, last_name, name_suffix].reject(&:blank?) * ' '
  end
  alias_method :name,  :full_name  

  def public?
    stranger?
  end
  
  def private?
    friend?
  end

  def allows?( user, action )
    ( user.superuser? || ( user == self.entity ) || ( action == :view and self == self.entity.profile_for( user )))
  end
  
  ### collections ########################################################## 

  belongs_to :wiki
  
  has_many   :locations,       :dependent => :destroy#, :order=>"preferred desc"
  has_many   :email_addresses, :dependent => :destroy#, :order=>"preferred desc"
  has_many   :im_addresses,    :dependent => :destroy###, :order=>"preferred desc"
  has_many   :web_resources,   :dependent => :destroy
  has_many   :phone_numbers,   :dependent => :destroy#, :order=>"preferred desc"
  has_many   :languages,       :dependent => :destroy#, :order=>"preferred desc"
  #has_many   :websites,        :dependent => :destroy#, :order=>"preferred desc"
  has_many   :notes,           :dependent => :destroy do #, :order=>"preferred desc" do
    def [] ( note_type )
      detect { |n| n.note_type == note_type } or
      find_or_create_by_note_type note_type.to_s
    end
  end

  def note_for(note_type)
    notes.detect { |n| n.note_type == note_type } or
    notes.find_or_create_by_note_type note_type.to_s
  end
  #validates_associated :email_addresses

  def save_public_version
    if friend? and entity.respond_to? :public_profile
      public_version = entity.public_profile || entity.build_public_profile
      public_version.attributes = self.attributes.merge( :friend => false, :stranger => true )
      notes.each { |n| public_version.note_for(n.note_type).update_attribute :body, n.body }
      public_version.web_resources.delete_all
      web_resources.each { |srv| public_version.web_resources.build(srv.attributes) }
      public_version.locations.delete_all
      simple_locations = locations.map { |loc| { :location_type => loc.location_type, :city => loc.city, :state => loc.state } }.map(&:to_a).uniq.map { |arr| Hash[*arr.flatten] }
      simple_locations.each { |loc_attr| public_version.locations.build loc_attr }
      public_version.save
    end
  end

end
