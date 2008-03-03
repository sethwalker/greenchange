class ExternalMedias < ActiveRecord::Migration
  def self.up
    create_table :external_medias do |t|
      t.column :media_key, :string
      t.column :media_url, :string
      t.column :media_thumbnail_url, :string
      t.column :media_embed, :string
      t.column :type, :string
    end
  end

  def self.down
    drop_table :external_medias
  end
end
