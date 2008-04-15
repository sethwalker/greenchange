class ContactRequest < ActiveRecord::Base
  include Approvable

  belongs_to :user
  belongs_to :contact, :class_name => 'User'
  alias :sender :user

  def invitation?
    false
  end
  def after_approved
    Contact.find_or_create_by_user_id_and_contact_id(user_id, contact_id)
  end
end
