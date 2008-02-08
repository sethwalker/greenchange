class CrabgrassDocumentTypesToVersion1195250189AndCrabgrassIssuesToVersion1202325544 < ActiveRecord::Migration
  def self.up
    Rails.plugins["crabgrass_document_types"].migrate(1195250189)
    Rails.plugins["crabgrass_issues"].migrate(1202325544)
  end

  def self.down
    Rails.plugins["crabgrass_document_types"].migrate(1199730694)
    Rails.plugins["crabgrass_issues"].migrate(1199730694)
  end
end
