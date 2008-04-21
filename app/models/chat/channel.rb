class Chat::Channel < ActiveRecord::Base

  set_table_name 'chat_channels'
  belongs_to :group
  
  has_many :channels_users, :dependent => :delete_all#, :class_name => 'Chat::ChannelsUsers'
  #alias :channels_users :chat_channels_users

  has_many :users, :through => :channels_users #do
    #def push_with_attributes(user, join_attrs)
    #  Chat::ChannelsUser.with_scope(:create => join_attrs) { self << user }
    #end
#  end

#    def cleanup
#      connection.execute("DELETE FROM channels_users WHERE last_seen < DATE_SUB(\'#{ Time.now.strftime("%Y-%m-%d %H:%M:%S") }\', INTERVAL 1 MINUTE) OR last_seen IS NULL")
#    end
  
  has_many :messages, :order => 'created_at asc', :dependent => :delete_all, :class_name => 'Chat::Message'#, :local_key => 'chat_channel_id'
#  alias :messages :chat_messages
#  do
#    def since(last_seen_id)
#      find(:all, :conditions => ['id > ?', last_seen_id])
#    end
#  end
  
  def destroy_old_messages
    count = messages.count
    if count > keep
      delete_this_many = count - keep
      connection.execute "DELETE FROM chat_messages WHERE channel_id = %s ORDER BY id ASC LIMIT %s" % [self.id, delete_this_many]
    end
  end
    
  def latest_messages(qty = nil)
    qty ||= keep
    messages.find(:all, :limit => qty, :order => 'created_at DESC').reverse
  end
  
  def users_just_left
    User.find_by_sql(["SELECT u.* FROM users u, chat_channels_users cu WHERE cu.last_seen < DATE_SUB(?, INTERVAL 1 MINUTE) AND cu.user_id = u.id AND cu.channel_id = ?", Time.now.strftime("%Y-%m-%d %H:%M:%S"), self.id])
  end
  
  def active_channel_users
    @active_channel_users ||= Chat::ChannelsUser.find_by_sql(["SELECT * FROM chat_channels_users cu WHERE cu.last_seen >= DATE_SUB(?, INTERVAL 1 MINUTE) AND cu.channel_id = ?", Time.now.strftime("%Y-%m-%d %H:%M:%S"), self.id])
  end
  
  def keep
    500
  end

  def record_seeing_user(user, typing_action)
    # use typing_delta to change typing counter, but keep value bounded between -2 and 2
    typing = 0
    c_user = self.channels_users.find_by_user_id(user.id)
    if c_user and c_user.typing?
      typing = c_user.typing
      if typing_action == 2 and typing < 2
        typing += 2
      elsif typing_action == -2
        typing = -2
      elsif typing_action == 0 and typing > 0
        typing -= 1
      end
    end
    
    self.users.delete(user)
    self.channel_users.create :user => user,  :last_seen => Time.now, :typing => 10 
  end
end
