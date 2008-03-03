class WikiTypes < ActiveRecord::Migration
  def self.up
    add_column :wikis, :type, :string
  end

  def self.down
    remove_column :wikis, :type
  end
end
