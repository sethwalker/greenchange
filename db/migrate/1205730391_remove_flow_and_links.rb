class RemoveFlowAndLinks < ActiveRecord::Migration
  def self.up
    remove_index :pages, :name => "index_pages_on_flow"
    remove_column :pages, :flow
    drop_table :links
  end

  def self.down
    raise IrreversibleMigration
  end
end
