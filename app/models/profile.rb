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
  
  ### collections ########################################################## 

  belongs_to :wiki
  #belongs_to :photo
  #belongs_to :layout
  
  has_many   :locations,       :dependent => :destroy#, :order=>"preferred desc"
  has_many   :email_addresses, :dependent => :destroy#, :order=>"preferred desc"
  has_many   :im_addresses,    :dependent => :destroy###, :order=>"preferred desc"
  has_many   :phone_numbers,   :dependent => :destroy#, :order=>"preferred desc"
  has_many   :websites,        :dependent => :destroy#, :order=>"preferred desc"
  has_many   :notes,           :dependent => :destroy do #, :order=>"preferred desc" do
    def [] ( note_type )
      find_or_create_by_note_type note_type.to_s
    end
  end

  #validates_associated :email_addresses

end
