# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 40) do

  create_table "assets", :force => true do |t|
    t.column "parent_id",    :integer
    t.column "content_type", :string
    t.column "filename",     :string
    t.column "thumbnail",    :string
    t.column "size",         :integer
    t.column "width",        :integer
    t.column "height",       :integer
    t.column "page_id",      :integer
    t.column "created_at",   :datetime
    t.column "version",      :integer
  end

  create_table "avatars", :force => true do |t|
    t.column "data",   :binary
    t.column "public", :boolean, :default => false
  end

  create_table "categories", :force => true do |t|
  end

  create_table "channels", :force => true do |t|
    t.column "name",     :string
    t.column "group_id", :integer
    t.column "public",   :boolean, :default => false
  end

  create_table "channels_users", :force => true do |t|
    t.column "channel_id", :integer
    t.column "user_id",    :integer
    t.column "last_seen",  :datetime
  end

  create_table "contacts", :id => false, :force => true do |t|
    t.column "user_id",    :integer
    t.column "contact_id", :integer
  end

  create_table "discussions", :force => true do |t|
    t.column "posts_count",  :integer,  :default => 0
    t.column "replied_at",   :datetime
    t.column "replied_by",   :integer
    t.column "last_post_id", :integer
    t.column "page_id",      :integer
  end

  create_table "group_participations", :force => true do |t|
    t.column "group_id", :integer
    t.column "page_id",  :integer
    t.column "access",   :integer
  end

  create_table "groups", :force => true do |t|
    t.column "name",            :string
    t.column "full_name",       :string
    t.column "summary",         :string
    t.column "url",             :string
    t.column "type",            :string
    t.column "parent_id",       :integer
    t.column "admin_group_id",  :integer
    t.column "council",         :boolean
    t.column "created_at",      :datetime
    t.column "updated_at",      :datetime
    t.column "avatar_id",       :integer
    t.column "private_home_id", :integer
    t.column "public_home_id",  :integer
    t.column "style",           :string
  end

  add_index "groups", ["name"], :name => "index_groups_on_name"

  create_table "groups_to_committees", :force => true do |t|
    t.column "group_id",     :integer
    t.column "committee_id", :integer
  end

  create_table "groups_to_networks", :force => true do |t|
    t.column "group_id",     :integer
    t.column "network_id",   :integer
    t.column "council_id",   :integer
    t.column "delegates_id", :integer
  end

  create_table "links", :id => false, :force => true do |t|
    t.column "page_id",       :integer
    t.column "other_page_id", :integer
  end

  create_table "memberships", :force => true do |t|
    t.column "group_id",   :integer
    t.column "user_id",    :integer
    t.column "created_at", :datetime
    t.column "page_id",    :integer
  end

  create_table "messages", :force => true do |t|
    t.column "created_at",  :datetime
    t.column "type",        :string
    t.column "content",     :text
    t.column "channel_id",  :integer
    t.column "sender_id",   :integer
    t.column "sender_name", :string
    t.column "level",       :string
  end

  add_index "messages", ["channel_id"], :name => "index_messages_on_channel_id"

  create_table "page_tools", :force => true do |t|
    t.column "page_id",   :integer
    t.column "tool_id",   :integer
    t.column "tool_type", :string
  end

  create_table "pages", :force => true do |t|
    t.column "title",              :string
    t.column "created_at",         :datetime
    t.column "updated_at",         :datetime
    t.column "happens_at",         :datetime
    t.column "resolved",           :boolean,  :default => true
    t.column "public",             :boolean
    t.column "created_by_id",      :integer
    t.column "updated_by_id",      :integer
    t.column "summary",            :string
    t.column "type",               :string
    t.column "message_count",      :integer,  :default => 0
    t.column "data_id",            :integer
    t.column "data_type",          :string
    t.column "contributors_count", :integer,  :default => 0
    t.column "posts_count",        :integer,  :default => 0
    t.column "name",               :string
    t.column "group_id",           :integer
    t.column "group_name",         :string
    t.column "updated_by_login",   :string
    t.column "created_by_login",   :string
  end

  add_index "pages", ["name"], :name => "index_pages_on_name"

  create_table "pictures", :force => true do |t|
    t.column "comment",       :string
    t.column "name",          :string
    t.column "content_type",  :string
    t.column "data",          :binary
    t.column "created_by_id", :integer
    t.column "created_at",    :datetime
    t.column "thumb",         :binary
    t.column "type",          :string
  end

  create_table "polls", :force => true do |t|
    t.column "type", :string
  end

  create_table "possibles", :force => true do |t|
    t.column "name",    :string
    t.column "action",  :text
    t.column "poll_id", :integer
  end

  create_table "posts", :force => true do |t|
    t.column "user_id",       :integer
    t.column "discussion_id", :integer
    t.column "body",          :text
    t.column "body_html",     :text
    t.column "created_at",    :datetime
    t.column "updated_at",    :datetime
  end

  add_index "posts", ["user_id"], :name => "index_posts_on_user_id"
  add_index "posts", ["discussion_id", "created_at"], :name => "index_posts_on_discussion_id"

  create_table "taggings", :force => true do |t|
    t.column "taggable_id",   :integer
    t.column "tag_id",        :integer
    t.column "taggable_type", :string
  end

  create_table "tags", :force => true do |t|
    t.column "name", :string
  end

  create_table "task_lists", :force => true do |t|
  end

  create_table "tasks", :force => true do |t|
    t.column "task_list_id",     :integer
    t.column "name",             :string,  :limit => 50
    t.column "description",      :string
    t.column "description_html", :string
    t.column "completed",        :boolean,               :default => false
    t.column "position",         :integer
  end

  create_table "tasks_users", :id => false, :force => true do |t|
    t.column "user_id", :integer
    t.column "task_id", :integer
  end

  create_table "user_participations", :force => true do |t|
    t.column "page_id",       :integer
    t.column "user_id",       :integer
    t.column "folder_id",     :integer
    t.column "access",        :integer
    t.column "viewed_at",     :datetime
    t.column "changed_at",    :datetime
    t.column "watch",         :boolean
    t.column "star",          :boolean
    t.column "resolved",      :boolean,  :default => true
    t.column "viewed",        :boolean
    t.column "message_count", :integer,  :default => 0
  end

  create_table "users", :force => true do |t|
    t.column "login",                     :string
    t.column "email",                     :string
    t.column "crypted_password",          :string,   :limit => 40
    t.column "salt",                      :string,   :limit => 40
    t.column "created_at",                :datetime
    t.column "updated_at",                :datetime
    t.column "remember_token",            :string
    t.column "remember_token_expires_at", :datetime
    t.column "display_name",              :string
    t.column "language",                  :string,   :limit => 5
    t.column "avatar_id",                 :integer
    t.column "last_seen_at",              :datetime
    t.column "time_zone",                 :string,                 :default => "Pacific Time (US & Canada)"
  end

  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["last_seen_at"], :name => "index_users_on_last_seen_at"

  create_table "votes", :force => true do |t|
    t.column "possible_id", :integer
    t.column "user_id",     :integer
    t.column "created_at",  :datetime
    t.column "value",       :integer
    t.column "comment",     :string
  end

  create_table "wiki_versions", :force => true do |t|
    t.column "wiki_id",    :integer
    t.column "version",    :integer
    t.column "body",       :text
    t.column "body_html",  :text
    t.column "updated_at", :datetime
    t.column "user_id",    :integer
  end

  create_table "wikis", :force => true do |t|
    t.column "body",         :text
    t.column "body_html",    :text
    t.column "updated_at",   :datetime
    t.column "user_id",      :integer
    t.column "lock_version", :integer,  :default => 0
    t.column "locked_at",    :datetime
    t.column "locked_by_id", :integer
  end

end
