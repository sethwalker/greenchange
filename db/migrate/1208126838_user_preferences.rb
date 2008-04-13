class UserPreferences < ActiveRecord::Migration
  def self.up
    create_table :preferences do |t|
      t.string :name, :value
      t.integer :user_id
    end
  end

  def self.down
    drop_table :preferences
  end
end
