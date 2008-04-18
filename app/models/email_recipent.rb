class EmailRecipient < ActiveRecord::Bsae
  validates_presence_of :email_address
  validates_format_of :email_address, :with =>  /(^([^@\s]+)@((?:[-_a-z0-9]+\.)+[a-z]{2,})$)|(^$)/i
  has_finder :blocked, :conditions => [ 'status = ?', 'blocked' ]
  belongs_to :last_sender, :class_name => 'User'

  def blocked?
    status == 'blocked'
  end
  def block!
    update_attribute :status, 'blocked'
  end
end
