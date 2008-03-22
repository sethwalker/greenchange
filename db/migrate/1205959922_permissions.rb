class Permissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      # plumbing
      t.column :resource_type,  :string, :limit => 64
      t.column :resource_id,    :integer
      t.column :grantor_type,   :string, :limit => 64
      t.column :grantor_id,     :integer
      t.column :grantee_type,   :string, :limit => 64
      t.column :grantee_id,     :integer

      # load
      t.column :view,           :boolean
      t.column :edit,           :boolean
      t.column :participate,    :boolean
      t.column :admin,          :boolean
    end
  end

  def self.down
    drop_table :permissions
  end
end
