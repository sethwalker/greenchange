class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table "messages" do |t|
      t.integer :sender_id, :recipient_id, :group_id
      t.boolean :sender_copy
      t.text :body
      t.string :state, :subject, :type
      t.string :invitable_id, :invitable_type
      t.string :requestable_id, :requestable_type
      t.timestamps
    end
  end

  def self.down
    drop_table "messages"
  end
end
