class ChatMessage < ActiveRecord::Base

  set_table_name 'chat_messages'
  belongs_to :channel, :class_name => 'ChatChannel'#, :foreign_key => 'chat_channel_id'
  #alias :channel :chat_channel

  belongs_to :sender, :class_name => 'User', :foreign_key => 'sender_id'
  has_finder :since, lambda { |last_seen_id| { :conditions => ['id > ?', last_seen_id] } }
  
  #validates_length_of :content, :in => 1..1000
  
  def before_create
    if sender
      self.sender_name = sender.login
    end
    true
  end
  
end
