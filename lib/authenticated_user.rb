# == Schema Information
# Schema version: 24
#
# Table name: users
#
#  id                        :integer(11)   not null, primary key
#  login                     :string(255)   
#  email                     :string(255)   
#  crypted_password          :string(40)    
#  salt                      :string(40)    
#  created_at                :datetime      
#  updated_at                :datetime      
#  remember_token            :string(255)   
#  remember_token_expires_at :datetime      
#  display_name              :string(255)   
#  time_zone                 :string(255)   
#  language                  :string(5)     
#  avatar_id                 :integer(11)   
#

##
# this is the user model generated by acts_as_authenticated plugin
# crabgrass specific model is called "User", which is a subclass
# of "AuthenticatedUser".
##

require 'digest/sha1'
module AuthenticatedUser 
  #set_table_name 'users'

  def self.included(base)
    base.extend   ClassMethods
    base.instance_eval do
      # a class attr which is set to the currently logged in user
      cattr_accessor :current
      
      # Virtual attribute for the unencrypted password
      attr_accessor :password

      validates_presence_of     :login
      validates_presence_of     :password,                   :if => :password_required?
      validates_presence_of     :password_confirmation,      :if => :password_required?
      validates_length_of       :password, :within => 4..40, :if => :password_required?
      validates_confirmation_of :password,                   :if => :password_required?
      validates_format_of       :login, :with => /^[a-z0-9]+([-_]*[a-z0-9]+){1,39}$/
      validates_length_of       :login, :within => 3..40
      validates_uniqueness_of   :login, :case_sensitive => false
      before_save :encrypt_password
    end
  end
  module ClassMethods
    
    # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
    def authenticate(login, password)
      u = find_by_login(login) # need to get the salt
      u && u.authenticated?(password) ? u : nil
    end

    # Encrypts some data with the salt.
    def encrypt(password, salt)
      Digest::SHA1.hexdigest("--#{salt}--#{password}--")
    end

    def find_for_forget(email)
      find :first, :conditions => ['email = ?', email]
    end

  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  #methods used for password reminders
  def forgot_password
    @forgotten_password = true
    self.make_password_reset_code
  end

  def reset_password
    update_attribute :password_reset_code, nil
    @reset_password = true
  end

  #user observer uses these methods
  def recently_forgot_password?
    @forgotten_password
  end

  def recently_reset_password?
    @reset_password
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end

    def make_password_reset_code
      self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
  
end

