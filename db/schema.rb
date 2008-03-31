# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 1206835544) do

  create_table "asset_versions", :force => true do |t|
    t.integer  "asset_id"
    t.integer  "version"
    t.integer  "parent_id"
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "page_id"
    t.datetime "created_at"
    t.string   "versioned_type"
    t.datetime "updated_at"
  end

  add_index "asset_versions", ["asset_id"], :name => "index_asset_versions_asset_id"
  add_index "asset_versions", ["parent_id"], :name => "index_asset_versions_parent_id"
  add_index "asset_versions", ["version"], :name => "index_asset_versions_version"
  add_index "asset_versions", ["page_id"], :name => "index_asset_versions_page_id"

  create_table "assets", :force => true do |t|
    t.integer  "parent_id"
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.string   "type"
    t.integer  "page_id"
    t.datetime "created_at"
    t.integer  "version"
  end

  add_index "assets", ["parent_id"], :name => "index_assets_parent_id"
  add_index "assets", ["version"], :name => "index_assets_version"
  add_index "assets", ["page_id"], :name => "index_assets_page_id"

  create_table "avatars", :force => true do |t|
    t.binary  "data",   :default => "",    :null => false
    t.boolean "public", :default => false
  end

  create_table "bookmarks", :force => true do |t|
    t.integer "page_id"
    t.string  "url"
    t.text    "description"
    t.integer "user_id"
  end

  add_index "bookmarks", ["page_id"], :name => "index_bookmarks_on_page_id"
  add_index "bookmarks", ["user_id"], :name => "index_bookmarks_on_user_id"

  create_table "categories", :force => true do |t|
  end

  create_table "channels", :force => true do |t|
    t.string  "name"
    t.integer "group_id"
    t.boolean "public",   :default => false
  end

  add_index "channels", ["group_id"], :name => "index_channels_group_id"

  create_table "channels_users", :force => true do |t|
    t.integer  "channel_id"
    t.integer  "user_id"
    t.datetime "last_seen"
    t.integer  "status"
  end

  add_index "channels_users", ["channel_id", "user_id"], :name => "index_channels_users"

  create_table "collectings", :force => true do |t|
    t.integer  "collection_id"
    t.integer  "collectable_id"
    t.integer  "created_by"
    t.integer  "position"
    t.string   "collectable_type"
    t.string   "permission"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "collections", :force => true do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.integer "page_id"
    t.string  "permission"
  end

  create_table "contact_requests", :force => true do |t|
    t.integer  "user_id"
    t.integer  "contact_id"
    t.string   "state"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contact_requests", ["user_id", "contact_id", "state"], :name => "index_user_contact_state"
  add_index "contact_requests", ["contact_id", "user_id", "state"], :name => "index_contact_user_state"

  create_table "contacts", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "contact_id"
  end

  add_index "contacts", ["contact_id", "user_id"], :name => "index_contacts"

  create_table "discussions", :force => true do |t|
    t.integer  "posts_count",  :default => 0
    t.datetime "replied_at"
    t.integer  "replied_by"
    t.integer  "last_post_id"
    t.integer  "page_id"
  end

  add_index "discussions", ["page_id"], :name => "index_discussions_page_id"

  create_table "document_metas", :force => true do |t|
    t.string  "creator"
    t.string  "creator_url"
    t.string  "source"
    t.string  "source_url"
    t.date    "published_at"
    t.integer "wiki_id"
  end

  add_index "document_metas", ["wiki_id"], :name => "index_document_metas_on_wiki_id"

  create_table "email_addresses", :force => true do |t|
    t.integer "profile_id"
    t.boolean "preferred",     :default => false
    t.string  "email_type"
    t.string  "email_address"
  end

  add_index "email_addresses", ["profile_id"], :name => "email_addresses_profile_id_index"

  create_table "events", :force => true do |t|
    t.text    "description"
    t.text    "description_html"
    t.boolean "is_all_day",       :default => false
    t.boolean "is_cancelled",     :default => false
    t.boolean "is_tentative",     :default => true
    t.string  "address1"
    t.string  "address2"
    t.string  "city"
    t.string  "state"
    t.string  "postal_code"
    t.string  "country"
    t.text    "directions"
    t.string  "time_zone"
    t.float   "latitude"
    t.float   "longitude"
  end

  create_table "external_medias", :force => true do |t|
    t.string "media_key"
    t.string "media_url"
    t.string "media_thumbnail_url"
    t.string "media_embed"
    t.string "type"
  end

  create_table "federations", :force => true do |t|
    t.integer "group_id"
    t.integer "network_id"
    t.integer "council_id"
    t.integer "delegates_id"
  end

  create_table "group_participations", :force => true do |t|
    t.integer "group_id"
    t.integer "page_id"
    t.integer "access"
  end

  add_index "group_participations", ["group_id", "page_id"], :name => "index_group_participations"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.string   "full_name"
    t.string   "summary"
    t.string   "url"
    t.string   "type"
    t.integer  "parent_id"
    t.integer  "admin_group_id"
    t.boolean  "council"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "avatar_id"
    t.string   "style"
    t.string   "parent_name"
  end

  add_index "groups", ["name"], :name => "index_groups_on_name"
  add_index "groups", ["parent_id"], :name => "index_groups_parent_id"

  create_table "im_addresses", :force => true do |t|
    t.integer "profile_id"
    t.boolean "preferred",  :default => false
    t.string  "im_type"
    t.string  "im_address"
  end

  add_index "im_addresses", ["profile_id"], :name => "im_addresses_profile_id_index"

  create_table "issue_identifications", :force => true do |t|
    t.integer "issue_id",               :default => 0,  :null => false
    t.integer "issue_identifying_id",   :default => 0,  :null => false
    t.string  "issue_identifying_type", :default => "", :null => false
  end

  add_index "issue_identifications", ["issue_id", "issue_identifying_id", "issue_identifying_type"], :name => "index_issue_identifications", :unique => true

  create_table "issues", :force => true do |t|
    t.string "name",        :default => "", :null => false
    t.text   "description"
  end

  add_index "issues", ["name"], :name => "index_issues_on_name", :unique => true

  create_table "locations", :force => true do |t|
    t.integer "profile_id"
    t.boolean "preferred",     :default => false
    t.string  "location_type"
    t.string  "street"
    t.string  "city"
    t.string  "state"
    t.string  "postal_code"
    t.string  "geocode"
    t.string  "country_name"
  end

  add_index "locations", ["profile_id"], :name => "locations_profile_id_index"

  create_table "membership_requests", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.string   "state"
    t.integer  "approved_by"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "membership_requests", ["user_id", "group_id", "state"], :name => "index_user_group_state"
  add_index "membership_requests", ["group_id", "user_id", "state"], :name => "index_group_user_state"

  create_table "memberships", :force => true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.integer  "page_id"
    t.datetime "created_at"
    t.string   "role",       :limit => 20, :default => "member"
  end

  add_index "memberships", ["group_id", "user_id", "role"], :name => "index_group_user_role", :unique => true
  add_index "memberships", ["user_id", "group_id", "role"], :name => "index_user_group_role", :unique => true

  create_table "messages", :force => true do |t|
    t.datetime "created_at"
    t.string   "type"
    t.text     "content"
    t.integer  "channel_id"
    t.integer  "sender_id"
    t.string   "sender_name"
    t.string   "level"
  end

  add_index "messages", ["channel_id"], :name => "index_messages_on_channel_id"
  add_index "messages", ["sender_id"], :name => "index_messages_channel"

  create_table "page_tools", :force => true do |t|
    t.integer "page_id"
    t.integer "tool_id"
    t.string  "tool_type"
  end

  add_index "page_tools", ["page_id", "tool_id"], :name => "index_page_tools"

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "resolved",           :default => true
    t.boolean  "public"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.text     "summary"
    t.string   "type"
    t.integer  "message_count",      :default => 0
    t.integer  "data_id"
    t.string   "data_type"
    t.integer  "contributors_count", :default => 0
    t.integer  "posts_count",        :default => 0
    t.string   "name"
    t.integer  "group_id"
    t.string   "group_name"
    t.string   "updated_by_login"
    t.string   "created_by_login"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean  "public_edit"
    t.boolean  "public_participate"
  end

  add_index "pages", ["name"], :name => "index_pages_on_name"
  add_index "pages", ["created_by_id"], :name => "index_page_created_by_id"
  add_index "pages", ["updated_by_id"], :name => "index_page_updated_by_id"
  add_index "pages", ["group_id"], :name => "index_page_group_id"
  add_index "pages", ["type"], :name => "index_pages_on_type"
  add_index "pages", ["public"], :name => "index_pages_on_public"
  add_index "pages", ["resolved"], :name => "index_pages_on_resolved"
  add_index "pages", ["created_at"], :name => "index_pages_on_created_at"
  add_index "pages", ["updated_at"], :name => "index_pages_on_updated_at"
  add_index "pages", ["starts_at"], :name => "index_pages_on_starts_at"
  add_index "pages", ["ends_at"], :name => "index_pages_on_ends_at"

  create_table "permissions", :force => true do |t|
    t.string  "resource_type", :limit => 64
    t.integer "resource_id"
    t.string  "grantor_type",  :limit => 64
    t.integer "grantor_id"
    t.string  "grantee_type",  :limit => 64
    t.integer "grantee_id"
    t.boolean "view"
    t.boolean "edit"
    t.boolean "participate"
    t.boolean "admin"
  end

  create_table "phone_numbers", :force => true do |t|
    t.integer "profile_id"
    t.boolean "preferred",         :default => false
    t.string  "provider"
    t.string  "phone_number_type"
    t.string  "phone_number"
  end

  add_index "phone_numbers", ["profile_id"], :name => "phone_numbers_profile_id_index"

  create_table "polls", :force => true do |t|
    t.string "type"
  end

  create_table "possibles", :force => true do |t|
    t.string  "name"
    t.text    "action"
    t.integer "poll_id"
    t.text    "description"
    t.text    "description_html"
    t.integer "position"
  end

  add_index "possibles", ["poll_id"], :name => "index_possibles_poll_id"

  create_table "posts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "discussion_id"
    t.text     "body"
    t.text     "body_html"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["user_id"], :name => "index_posts_on_user_id"
  add_index "posts", ["discussion_id", "created_at"], :name => "index_posts_on_discussion_id"

  create_table "profile_notes", :force => true do |t|
    t.integer "profile_id"
    t.boolean "preferred",  :default => false
    t.string  "note_type"
    t.text    "body"
  end

  add_index "profile_notes", ["profile_id"], :name => "profile_notes_profile_id_index"

  create_table "profiles", :force => true do |t|
    t.integer  "entity_id"
    t.string   "entity_type"
    t.string   "language",               :limit => 5
    t.boolean  "stranger"
    t.boolean  "peer"
    t.boolean  "friend"
    t.boolean  "foe"
    t.string   "name_prefix"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "name_suffix"
    t.string   "nickname"
    t.string   "role"
    t.string   "organization"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "birthday",               :limit => 8
    t.boolean  "fof"
    t.string   "summary"
    t.integer  "wiki_id"
    t.integer  "photo_id"
    t.integer  "layout_id"
    t.boolean  "may_see"
    t.boolean  "may_see_committees"
    t.boolean  "may_see_networks"
    t.boolean  "may_see_members"
    t.boolean  "may_request_membership"
    t.integer  "membership_policy"
    t.boolean  "may_see_groups"
    t.boolean  "may_see_contacts"
    t.boolean  "may_request_contact"
    t.boolean  "may_pester"
    t.boolean  "may_burden"
    t.boolean  "may_spy"
  end

  add_index "profiles", ["entity_id", "entity_type", "language", "stranger", "peer", "friend", "foe"], :name => "profiles_index"

  create_table "ratings", :force => true do |t|
    t.integer  "rating",                      :default => 0
    t.datetime "created_at",                                  :null => false
    t.string   "rateable_type", :limit => 15, :default => "", :null => false
    t.integer  "rateable_id",                 :default => 0,  :null => false
    t.integer  "user_id",                     :default => 0,  :null => false
  end

  add_index "ratings", ["user_id"], :name => "fk_ratings_user"
  add_index "ratings", ["rateable_type", "rateable_id"], :name => "fk_ratings_rateable"

  create_table "taggings", :force => true do |t|
    t.integer "taggable_id"
    t.integer "tag_id"
    t.string  "taggable_type"
  end

  add_index "taggings", ["taggable_type", "taggable_id"], :name => "fk_taggings_taggable"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  add_index "tags", ["name"], :name => "tags_name"

  create_table "task_lists", :force => true do |t|
  end

  create_table "tasks", :force => true do |t|
    t.integer  "task_list_id"
    t.string   "name"
    t.text     "description"
    t.text     "description_html"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "completed_at"
    t.datetime "due_at"
  end

  add_index "tasks", ["task_list_id"], :name => "index_tasks_task_list_id"
  add_index "tasks", ["task_list_id", "completed_at", "position"], :name => "index_tasks_completed_positions"

  create_table "tasks_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "task_id"
  end

  add_index "tasks_users", ["user_id", "task_id"], :name => "index_tasks_users_ids"

  create_table "user_participations", :force => true do |t|
    t.integer  "page_id"
    t.integer  "user_id"
    t.integer  "folder_id"
    t.integer  "access"
    t.datetime "viewed_at"
    t.datetime "changed_at"
    t.boolean  "watch",         :default => false
    t.boolean  "star"
    t.boolean  "resolved",      :default => true
    t.boolean  "viewed"
    t.integer  "message_count", :default => 0
    t.boolean  "attend",        :default => false
    t.text     "notice"
  end

  add_index "user_participations", ["page_id"], :name => "index_user_participations_page"
  add_index "user_participations", ["user_id"], :name => "index_user_participations_user"
  add_index "user_participations", ["page_id", "user_id"], :name => "index_user_participations_page_user"
  add_index "user_participations", ["viewed"], :name => "index_user_participations_viewed"
  add_index "user_participations", ["watch"], :name => "index_user_participations_watch"
  add_index "user_participations", ["star"], :name => "index_user_participations_star"
  add_index "user_participations", ["resolved"], :name => "index_user_participations_resolved"
  add_index "user_participations", ["attend"], :name => "index_user_participations_attend"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "display_name"
    t.string   "time_zone"
    t.string   "language",                  :limit => 5
    t.integer  "avatar_id"
    t.datetime "last_seen_at"
    t.integer  "version",                                 :default => 0
    t.binary   "direct_group_id_cache"
    t.binary   "all_group_id_cache"
    t.binary   "friend_id_cache"
    t.binary   "foe_id_cache"
    t.binary   "peer_id_cache"
    t.binary   "tag_id_cache"
    t.string   "password_reset_code",       :limit => 40
    t.boolean  "superuser",                               :default => false
  end

  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["last_seen_at"], :name => "index_users_on_last_seen_at"

  create_table "votes", :force => true do |t|
    t.integer  "possible_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.integer  "value"
    t.string   "comment"
  end

  add_index "votes", ["possible_id"], :name => "index_votes_possible"
  add_index "votes", ["possible_id", "user_id"], :name => "index_votes_possible_and_user"

  create_table "websites", :force => true do |t|
    t.integer "profile_id"
    t.boolean "preferred",  :default => false
    t.string  "site_title", :default => ""
    t.string  "site_url",   :default => ""
  end

  add_index "websites", ["profile_id"], :name => "websites_profile_id_index"

  create_table "wiki_versions", :force => true do |t|
    t.integer  "wiki_id"
    t.integer  "version"
    t.text     "body"
    t.text     "body_html"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "wiki_versions", ["wiki_id"], :name => "index_wiki_versions"
  add_index "wiki_versions", ["wiki_id", "updated_at"], :name => "index_wiki_versions_with_updated_at"

  create_table "wikis", :force => true do |t|
    t.text     "body"
    t.text     "body_html"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "lock_version", :default => 0
    t.datetime "locked_at"
    t.integer  "locked_by_id"
    t.string   "type"
  end

  add_index "wikis", ["user_id"], :name => "index_wikis_user_id"
  add_index "wikis", ["locked_by_id"], :name => "index_wikis_locked_by_id"

end
