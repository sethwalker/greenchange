class CrabgrassDocumentTypesToVersion1195250189 < ActiveRecord::Migration
  def self.up
    Rails.plugins["crabgrass_document_types"].migrate(1195250189)
  end

  def self.down
    Rails.plugins["crabgrass_document_types"].migrate(0)
  end
end
