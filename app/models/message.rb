class Message < ActiveRecord::Base

  belongs_to :sender, :class_name => 'User'
  belongs_to :recipient, :class_name => 'User'
  
  validates_presence_of :sender_id
  validates_presence_of :recipient_id, :if => :recipient_required?
  attr_accessor :recipients
  #acts_as_state_machine :initial => :pending, :column => 'read_state'

  has_finder :to, Proc.new { |recipient| { :conditions => [ "messages.recipient_id = ?", recipient ] }}
  has_finder :from, Proc.new { |sender|  { :conditions => [ "messages.sender_id = ?", sender ] }}
  has_finder :pending, { :conditions => [ "messages.state = ? or messages.state IS NULL", "pending" ] }

  def allows?( user, action )
    return false unless user == sender or user == recipient
    return true if action == :reply and user = recipient
    #simple_action = Permission.alias_for action
    ( user == sender and sender_copy ) ||
    ( user == recipient and not sender_copy ) 
    
  end

  # spawn creates multiple copies of a message, dependent on the value of the :recipients key. 
  # :recipients can be a comma or space delimited string, or an array of User logins
  # All other arguments to #spawn should be standard Message attributes
  def self.spawn( message_attrs )
    unless message_attrs[:recipients]
      return [self.new( message_attrs )]
    end
    message_attrs.symbolize_keys!
    names = message_attrs.delete(:recipients)
    unless names.respond_to?(:map) && !names.is_a?(String)
      names = names.squeeze(' ').gsub(/\s?,\s?/,',').split(/[,\s]/)
    end
    names.map do |recipient_login|
      user = User.find_by_login(recipient_login)
      self.create message_attrs.merge( :recipient_id => (user ? user.id : nil), :recipients => recipient_login )
    end
  end

  def recipient_required?
    true
  end

  after_create :notify_recipient
  def notify_recipient
    UserMailer.deliver_message_received(self) if recipient && recipient.receives_email_on('messages')
  end
end
