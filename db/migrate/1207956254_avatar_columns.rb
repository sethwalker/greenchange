class AvatarColumns < ActiveRecord::Migration
  def self.up
    add_column :pages, :image_filename, :string
    add_column :groups, :image_filename, :string
    add_column :users, :image_filename, :string
  end

  def self.down
    remove_column :pages, :image_filename, :string
    remove_column :groups, :image_filename, :string
    remove_column :users, :image_filename, :string
  end
end
