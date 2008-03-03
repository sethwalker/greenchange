class CreateBookmarks < ActiveRecord::Migration
  def self.up
    create_table :bookmarks do |t|
      t.column :page_id, :integer
      t.column :url, :string
      t.column :description, :text
      t.column :user_id, :integer
    end
    add_index :bookmarks, :page_id, :name => 'index_bookmarks_on_page_id'
    add_index :bookmarks, :user_id, :name => 'index_bookmarks_on_user_id'
  end

  def self.down
    drop_table :bookmarks
  end
end
