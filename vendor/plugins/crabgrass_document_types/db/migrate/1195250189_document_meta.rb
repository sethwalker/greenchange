class DocumentMeta < ActiveRecord::Migration
  def self.up
    create_table "document_metas" do |t|
      t.column "creator", :string
      t.column "creator_url", :string
      t.column "source", :string
      t.column "source_url", :string
      t.column "published_at", :date
      t.column "wiki_id", :integer
    end
    add_index :document_metas, :wiki_id, :name => "index_document_metas_on_wiki_id"
  end

  def self.down
    drop_table "document_metas"
  end
end
