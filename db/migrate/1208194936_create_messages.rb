class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table "messages" do |t|
      t.integer :sender_id, :recipient_id, :group_id
      t.text :body
      t.string :state, :subject, :type
      t.timestamps
    end
  end

  def self.down
    drop_table "messages"
  end
end
