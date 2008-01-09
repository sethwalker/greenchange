class CrabgrassExternalMediaToVersion1199730694 < ActiveRecord::Migration
  def self.up
    Rails.plugins["crabgrass_external_media"].migrate(1199730694)
  end

  def self.down
    Rails.plugins["crabgrass_external_media"].migrate(1195250189)
  end
end
