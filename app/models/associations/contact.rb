# user to user relationship

class Contact < ActiveRecord::Base
  belongs_to :user
  belongs_to :contact, :class_name => 'User', :foreign_key => :contact_id
  validates_uniqueness_of :contact_id, :scope => :user_id, :message => 'is already a contact'

  after_save :add_reciprocal_contact
  after_destroy :destroy_reciprocal_contact

  def add_reciprocal_contact
    #raise "adding recip"
    Contact.find_or_create_by_user_id_and_contact_id( contact_id, user_id )
  end

  def destroy_reciprocal_contact
    Contact.delete_all [ 'contact_id = ? and user_id = ?', user_id, contact_id ]
  end
    
end
