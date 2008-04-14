class MediaEmbedResize < ActiveRecord::Migration
  def self.up
    change_column :external_medias, :media_embed, :text
  end

  def self.down
    change_column :external_medias, :media_embed, :string
  end
end
