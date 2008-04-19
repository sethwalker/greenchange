class EmailRecipients < ActiveRecord::Migration
  def self.up
    create_table :email_recipients do |t|
      t.string :email, :first_name, :last_name
      t.integer :last_sender_id
      t.string :status
      t.string :retrieval_code, :limit => 8
      t.timestamps
    end
  end

  def self.down
    drop_table :email_recipients
  end
end
