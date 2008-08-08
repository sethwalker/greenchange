class BlogSubscriptions < ActiveRecord::Migration
  def self.up
    create_table 'subscriptions' do |t|
      t.string 'url'
      t.integer 'user_id'
      t.timestamps
      t.datetime 'last_updated_at'
    end
  end

  def self.down
    drop_table 'subscriptions'
  end
end
