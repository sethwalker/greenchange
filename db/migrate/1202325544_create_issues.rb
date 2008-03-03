class CreateIssues < ActiveRecord::Migration
  def self.up
    create_table :issues do |t|
      t.column :name, :string, :null => false
    end
    add_index :issues, :name, :unique => true, :name => 'index_issues_on_name'

    create_table :issue_identifications do |t|
      t.column :issue_id, :integer, :null => false
      t.column :issue_identifying_id, :integer, :null => false
      t.column :issue_identifying_type, :string, :null => false
    end
    add_index :issue_identifications, [:issue_id, :issue_identifying_id, :issue_identifying_type], :unique => true, :name => 'index_issue_identifications'
  end

  def self.down
    drop_table :issue_identifications
    drop_table :issues
  end
end
