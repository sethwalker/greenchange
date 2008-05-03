class EmailRecipient < ActiveRecord::Base
  validates_presence_of :email
  #validates_format_of :email, :with =>  /(^([^@\s]+)@((?:[-_a-z0-9]+\.)+[a-z]{2,})$)|(^$)/i
  validates_as_email :email
  has_finder :blocked, :conditions => [ 'status = ?', 'blocked' ]
  belongs_to :last_sender, :class_name => 'User'
  before_create :set_retrieval_hash

  def blocked?
    status == 'blocked'
  end
  def block!
    update_attribute :status, 'blocked'
  end

  def set_retrieval_hash
    self.retrieval_code = 
      ( ("%04x"*2 ) % ([nil]*2).map { rand(2**16) }).upcase
  end
end
