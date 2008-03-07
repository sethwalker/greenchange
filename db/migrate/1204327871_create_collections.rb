class CreateCollections < ActiveRecord::Migration
  def self.up
    #Tool::Collection has one Collection
    create_table :collections do |t|
      t.integer :user_id, :group_id, :page_id
      t.string :permission
    end
    #::Collection has_many :collectings
    #::Collection has_many :collectables :through :collectings
    create_table :collectings do |t|
      t.column :collection_id, :integer
      t.column :collectable_id, :integer
      t.column :created_by, :integer
      t.column :position, :integer
      t.column :collectable_type, :string
      t.column :permission, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :collectings
    drop_table :collections
  end
end
