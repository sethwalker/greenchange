class PublicPagePermissions < ActiveRecord::Migration
  def self.up
    add_column :pages, :public_edit, :boolean
    add_column :pages, :public_participate, :boolean
  end

  def self.down
    remove_column :pages, :public_participate
    remove_column :pages, :public_edit
  end
end
