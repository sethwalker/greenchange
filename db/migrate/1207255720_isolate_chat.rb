class IsolateChat < ActiveRecord::Migration
  def self.up
    rename_table 'channels', 'chat_channels' 
    rename_table 'channels_users', 'chat_channels_users' 
    rename_table 'messages', 'chat_messages' 
    #rename_column 'chat_channels_users', 'channel_id', 'chat_channel_id'
    #rename_column 'chat_messages', 'channel_id', 'chat_channel_id'
  end

  def self.down
    rename_table 'chat_messages' , 'messages'
    rename_table 'chat_channels_users' , 'channels_users'
    rename_table 'chat_channels' , 'channels'
    #rename_column 'messages', 'chat_channel_id', 'channel_id'
    #rename_column 'channels_users', 'chat_channel_id', 'channel_id'
  end
end
