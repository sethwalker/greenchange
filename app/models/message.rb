class Message < ActiveRecord::Base

  belongs_to :sender, :class_name => 'User'
  belongs_to :recipient, :class_name => 'User'
  #belongs_to :group
  #
  validates_presence_of :recipient_id, :sender_id

  def allows?( user, action )
    return false unless user == sender or user == recipient
    return true if action == :reply and user = recipient
    #simple_action = Permission.alias_for action
    ( user == sender and sender_copy ) ||
    ( user == recipient and not sender_copy ) 
    
  end

  def self.spawn( message_attrs )
    [1,1]
  end

end
