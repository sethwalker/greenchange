class ChatChannelsUser < ActiveRecord::Base

  set_table_name 'chat_channels_users'

  belongs_to :channel

  belongs_to :user
  
  # this function has an n+1 issue, i don't know why
  def active?
    channel.active_channel_users.include? self
  end
  
  def typing?
    return (self.status? and self.status > 0)
  end
end
